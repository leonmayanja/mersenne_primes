# Mersenne Primes

![alt text](image/prime_numbers.png "Prime Numbers")

## Project Overview
In this project, I set up an EC2 instance and install mprime software using a bash script to find Mersenne primes.

## What is a Mersenne Prime?
In order to answer this question, we first need to know what a prime number is. A number is prime when it is only divisible by itself or the number one. Here are a few examples of prime numbers:  2, 3, 5, 7, 11, ...

A Mersenne prime is a number of the form 2ᵖ – 1, in which P is also a prime number. They are named after Marin Mersenne, a French mathematician, who studied them in the early 17ᵗʰ century. The first Mersenne primes are 3, 7, 31, 127 (corresponding to P = 2, 3, 5, 7).

The largest known prime number, 2⁸²⁵⁸⁹⁹³³ − 1 (aka M82589933), is a Mersenne prime. It is more than twenty-three million (23,000,000) decimal digits long! Mersenne primes are something of a unicorn in the world of mathematics. Only fifty-one (51) are known to date! However, mathematicians still believe that there is an infinite number of Mersenne primes. Therefore, we have barely scratched the surface of this intriguing topic.

## Great Internet Mersenne Prime Search (GIMPS)
[GIMPS](https://www.mersenne.org/) is a collaborative project of volunteers who use freely available [software](https://www.mersenne.org/download/) (e.g. mprime) to search for Mersenne prime numbers. 

The software uses the idle processing power of your CPU to run a [test](https://en.wikipedia.org/wiki/Lucas%E2%80%93Lehmer_primality_test) (Lucas-Lehmer test) to determine whether or not a number is a Mersenne prime. Since the software only uses idle CPU processing power, even a normal PC can be used to find the next Mersenne prime. For example, the largest known prime number M82589933 (mentioned above) was found using an Intel Core i5-4590T processor!

## So What's the Point?
Finding a Mersenne prime will make you money. GIMPS [awards](https://www.mersenne.org/legal/#mpa:~:text=Research%20Discovery%20Awards-,Mersenne%20Prime%20Award%20of%20USD%20%243%2C000.00,the%20GIMPS%20PrimeNet%20server%20or%20to%20email%20their%20results%20to%20GIMPS.,-Privacy%20Policy) people for discovering Mersenne Primes. For discovering a Mersenne prime having fewer than 100,000,000 digits, GIMPS awards you with $3,000. Discovering a Mersenne prime with more than 100,000,000 digits earns you $50,000! It is like cryptocurrency mining for those of us who cannot afford to buy a dozen graphics cards or ASIC miners.

Prime numbers aslo play a crucial role in keeping data secure. For instance, [RSA encryption](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) relies on multiplying two large prime numbers together to help generate a key (public key). Data can be encrypted by anyone using the public key, but can only be decoded by someone who knows the two prime numbers.

## Steps
These are the steps I followed while trying to find a new Mersenne prime.

* Setup an AWS environment (VPC, subnet, security group, internet gateway, etc). The `create_resources.sh` script automatically does this.
* Launch EC2 instance with mprime software pre-installed. The `create_resources.sh` script automatically does this as well.
* SSH into the instance and `cd` into the `p95v307b9` directory.
* [Configure](https://www.mersenne.org/download/#newusers) mprime by running the command `./mprime -m`

Check out the `readme.txt` file in the `p95v307b9` directory for additional configuration information.

## Requirements
* AWS account
* [mprime](https://www.mersenne.org/download/#:~:text=Linux%3A%2064%2Dbit,f57bcc5c5d7403a4a7ee0d32abab01d8da114ed8%0ASHA256%3A%C2%A0d47d766c734d1cca4521cf7b37c1fe351c2cf1fbe5b7c70c457061a897a5a380) software
* Internet connection

Remember, the software provided by GIMPS can run on **any** modern computer. It is not limited to AWS EC2 instances. Check out this [link](https://www.mersenne.org/various/works.php) for more information.

## Clean Up AWS Environment
To avoid incurring any unexpected costs, use the `clean_up.sh` script to delete created resources.