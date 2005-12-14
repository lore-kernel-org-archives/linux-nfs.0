From: "Iozone" <capps@iozone.org>
Subject: Re: An interesting performance thing ?
Date: Wed, 14 Dec 2005 16:50:01 -0600
Message-ID: <016a01c60100$b9083b30$1500000a@americas.hpqcorp.net>
References: <00b901c600db$5d374960$1500000a@americas.hpqcorp.net>
 <17312.39940.985507.704832@cse.unsw.edu.au>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=iso-8859-1; reply-type=original
Cc: <wli@holomorphy.com>, "Chuck Lever" <cel@citi.umich.edu>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmfTE-0000Bl-Bs
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 14:51:36 -0800
Received: from vms044pub.verizon.net ([206.46.252.44])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EmfTD-0007jQ-1f
	for nfs@lists.sourceforge.net; Wed, 14 Dec 2005 14:51:36 -0800
Received: from cappsnc ([71.96.135.143])
 by vms044.mailsrvcs.net (Sun Java System Messaging Server 6.2-4.02 (built Sep
 9 2005)) with ESMTPA id <0IRI00E01FFD0SO3@vms044.mailsrvcs.net> for
 nfs@lists.sourceforge.net; Wed, 14 Dec 2005 16:50:04 -0600 (CST)
To: "Neil Brown" <neilb@suse.de>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Neil,

    Post at bottom:

----- Original Message ----- 
From: "Neil Brown" <neilb@suse.de>
To: "Iozone" <capps@iozone.org>
Cc: <wli@holomorphy.com>; "Chuck Lever" <cel@citi.umich.edu>; 
<nfs@lists.sourceforge.net>
Sent: Wednesday, December 14, 2005 4:26 PM
Subject: Re: An interesting performance thing ?


> On Wednesday December 14, capps@iozone.org wrote:
>> Neil,
>
> Hi, Don,
>
>>
>>     I think I have discovered an interesting performance anomaly.
>
> Indeed you have, thanks.
>
>>
>>     In the svcauth code there are places that do:
>>
>>        hash_long((unsigned long)item->m_addr.s_addr, IP_HASHBITS);
>>
>>     Ok... That seems reasonable, but then again...maybe not....
>
> No, perfectly reasonable.  I don't write "maybe reasonable" code.  It
> is either perfect, or rubbish :-)
>
>>
>>     I believe that s_addr is an IP address in Network Neutral format.
>>      (Big Endian)
>>
>>     So... When one is on a Little Endian system, the hash_long
>>     function gets handed a Big Endian value as a long, and
>>     later, via the magic of being a Little Endian system,
>>     gets byte swapped.
>>
>>     Step 1. 192.168.1.2 becomes 2.1.168.192 (byte swap)
>>
>>     Step 2.  The 32 bit IP address becomes a 64 bit long when
>>                  this code is compiled and run on an Opteron, or
>>                  an IA-64 system.
>>                  2.1.168.192 -> 0.0.0.0.2.1.168.192
>>     Step 3. Call the hash_long() and get back a hash value
>>                 that is IP_HASHBITS (8) in size.
>>
>>     You'll notice that the hash distribution is not nearly as
>>     good as one might believe.  If one would have done:
>>
>>         hash_long( inet_lnaof(item->m_addr.s_addr)),IP_HASHBITS)
>>
>>     Then the hash_long function would have done a nice job.
>
> True, but irrelevant.
> hash_long(X, 8) will take the top 8 bits of the result.  So pushing
> the noisy bits into the low order bits should have no significant
> effect.
> The fact that it does suggests that hash_long is broken.
>
> I wonder if I blame William or Chuck?  Maybe I'll just blame both.
> After all it is Christmas time and we should share the good will
> around :-)
>
>>
>> ---------
>>
>>     Now you say "Ok that's not too cool, but why is this really
>>     important ?"
>
> Oh, no.  I can easily see that it is important.  And I agree it is
> seriously uncool (like the weather down here is oz (aka .au)).
>
>
>>
>>         Well, it turns out that the RedHat EL 4 release has some issues
>>     with the locking around the buckets that this hash is being
>>     used to index into, and with the distribution being so not... it
>>     leads to a lock race, followed by a kernel dereference of null,
>>     followed shortly by angry phone calls.... True, the race needs
>>     to be fixed, but it sure would be nice if the pressure were a
>>     tad lower on the lock. It would greatly reduce the probability
>>     of the panic, and also improve the performance (scaling) of
>>     the system, if a few more buckets were used :-)
>
> What mainline kernel is RedHat EL 4 based on?
> I think I know the race you mean.... Funny how one writes buggy code,
> then fixes it, then finds it still existing in "enterprise" kernels
> months later. (SLES only gets it fixed in 9SP3).
>
>>
>>     I've talked this over with Charles, and Bruce, and they pointed
>>     me in your direction ...
>
> Go back to Charles and tell him I sent you :-)
>
>>
>>     How would you prefer to proceed ?
>>
>>         A. It's your code, and you would prefer to tinker without
>>             some bozo adding his two bits.
>
> Nonono, bozo bits are worth their weight in gold (sometimes).
>
>>
>>         B. You're way too busy to go after this, and would
>>             welcome a diff -u patch.
>
> In general, yes.  In this case, the patch would have been wrong.
>
>>
>>         C. You'll scratch your head, think about it, and get back
>>             after morning coffee :-)
>
> I'm a tea drinker, so that wouldn't work.
>
>>
>>         D. It will only take a few seconds to add the
>>                 inet_lnaof( ) to the offending lines, and it will be
>>                 done before you can say Jack Flash :-)
>
> It was 'Jack Robinson' in my day - no idea why.
>
>>
>>         E. Go away, you're bothering me :-)
>>
>
> Yeh, stop bothering me with such interesting puzzles.....
>
> If you look at the top of include/linux/hash.h  you will see a very
> helpful comment:
>
> /*
> * Knuth recommends primes in approximately golden ratio to the maximum
> * integer representable by a machine word for multiplicative hashing.
> * Chuck Lever verified the effectiveness of this technique:
> * http://www.citi.umich.edu/techreports/reports/citi-tr-00-1.pdf
> *
> * These primes are chosen to be bit-sparse, that is operations on
> * them can use shifts and additions instead of multiplications for
> * machines where multiplications are slow.
> */
>
> I think there is a tension between the 'close to golden ratio'
> requirement and the 'bit-sparse' requirement.  The prime chosen for
> 64bit work is
> #define GOLDEN_RATIO_PRIME 0x9e37fffffffc0001UL
> which is nicely bit-sparse, bit is a long way from the golden ratio
> which is 0x9E3779B97F4A7C15
> The closest prime to this is
>         0x9E3779B97F4A7C55
> which is not particularly bit-sparse, but produces much better
> distribution of hashes for IP addresses.
>
> In fact, I wouldn't be at all surprised if 'bit-sparse' tends to have a
> directly negative effect on hash quality when the variations in the
> input line up with the sparse bits (so to speak).
>
> Now I don't really know how much of an issue this 'bit sparseness' is
> for speed, and how much cost it would be to just change those
> shift/adds into a multiply.  But there is something definitely wrong
> with hash_long on 64bit, and I suspect it could affect more than just
> IP addresses.
>
> William, Chunk:  Any suggestions on whether a straight multiply would
> be too expensive, or what else we could do to make hash_long both fast
> and effective?
> Maybe we should just have 'hash32' and write 'hash64' as
>  hash32(x ^ hash32(x>>32));
>
> But then the current hash_long for 32bit doesn't work brilliantly when
> the variation is in the 3rd byte (i.e. within the mask 0x0f00).
>
> I wonder if http://burtleburtle.net/bob/hash/evahash.html might end up
> being better ... would need to do some serious tests.
>
> Help?
>
> NeilBrown
>
> btw, I did testing with the following little program
> called like:
>  for i in 0 8 16 24 ; do ./hashtest 0x00007659 $i 256; done
>                                       ^^^^^^^ random number.
>
> #include <stdio.h>
>
> unsigned hash(unsigned long val)
> {
> unsigned long long hash = val;
> /* hash *=  0x9e37fffffffc0001ULL;*/
> hash *= 11400714819323198549ULL;
> return (hash >> (64-8)) & 255;
> }
>
> main(int argc, char*argv[])
> {
> unsigned long start = strtoul(argv[1], 0);
> int shift = strtoul(argv[2], 0);
> int count = strtoul(argv[3], 0);
> int max = 0;
>
> int cnt[256];
> int i;
>
> for (i=0; i<256; i++)
> cnt[i] = 0;
>
> while (count) {
> cnt[hash(start)] ++;
> start += (1<<shift);
> count--;
> }
> count = 0;
> for (i=0; i<256; i++) {
> if (cnt[i])
> count++;
> if (cnt[i] > max)
> max = cnt[i];
> }
> printf("count %d/256 max %d\n", count, max);
> }
>
>

    In my tests I tried several IP addresses, and watched the resultant 
hash.
    I then tried the same experiment with inet_lnaof(x) and watched
    the resultant hash. In both cases on a 64 bit Little Endian system.

    Test results:

Testing byte 4 (least significant)
Input: 192.168.1.0 Hash-> 3e
Input: 192.168.1.0 Hash-with-inet_lnaof() -> 57
Input: 192.168.1.1 Hash-> 3e
Input: 192.168.1.1 Hash-with-inet_lnaof() -> c9
Input: 192.168.1.2 Hash-> 3e
Input: 192.168.1.2 Hash-with-inet_lnaof() -> 6b
Input: 192.168.1.3 Hash-> 3e
Input: 192.168.1.3 Hash-with-inet_lnaof() -> 8d
Input: 192.168.1.4 Hash-> 3e
Input: 192.168.1.4 Hash-with-inet_lnaof() -> 2f
Input: 192.168.1.5 Hash-> 3e
Input: 192.168.1.5 Hash-with-inet_lnaof() -> 40
Input: 192.168.1.6 Hash-> 3e
Input: 192.168.1.6 Hash-with-inet_lnaof() -> e2
Input: 192.168.1.7 Hash-> 3e
Input: 192.168.1.7 Hash-with-inet_lnaof() -> 4

    It looks like simply adding the hash_long(inet_lnaof(s_sddr),8)
    seems to do a better job than hash_long(s_addr,8) and is a
    pretty simple change.
    (low risk).

    I'll leave the discussion on GOLDEN to others, and
    go with simple/easy/works.  :-)

Enjoy,
Don Capps





-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
