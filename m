From: "Iozone" <capps@iozone.org>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Sat, 29 Jan 2005 11:25:18 -0600
Message-ID: <006701c50627$81122b70$06000800@americas.hpqcorp.net>
References: <41E816B3.4030702@mitre.org>	 <1105747170.28849.22.camel@lade.trondhjem.org>	 <41F13749.4090900@int-evry.fr> <1106329537.9849.68.camel@lade.trondhjem.org> <41FB6A10.6000001@int-evry.fr>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Cc: "Jeff Blaine" <jblaine@mitre.org>, <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuwLj-0006LU-W2
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 09:25:31 -0800
Received: from out012pub.verizon.net ([206.46.170.137] helo=out012.verizon.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CuwLg-0001US-JH
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 09:25:31 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
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

Jehan,

    Your results are what I would expect, given your
    configuration.

    1. The -e and -c will flush the writes from the
        client to the server, and from the server to
        its disks. However, if the file size is smaller than
        the amount of ram in the server, then a copy of the
        data still exists in the server's cache. Thus, client
        reads can be satisfied from the server's cache and
        wire speeds would be expected.
        If the file size is smaller than the amount of RAM in the
        client, then reads could be satisfied from the client's
        cache. Thus, the results that are higher than wire speed.
        Note: In Trond's runs, he uses the -U option. This option
        un-mounts and re-mounts the NFS filesystem on the
        client. This defeats the client's cache, even for files
        that would fit in the client's RAM.

    2. If you are using mmap, you may control the sync
        behavior with the -D and -G options. The -D causes
        msync() to occur with it happening async. The -G
        causes msync() to occur with it happening sync.

    3. It is not too surprising that you see 11 Mbytes/sec over
        100 Mbit. It's not very challenging for even a single
        disk, on the server, to satisfy this flow rate. It would
        be more interesting to use Gigabit networking, as this
        would put more load on the server's disk subsystem.

    4. If you need to exceed the RAM in the server (to measure
        without cache effects) then you could do so by using
        the -U option, or you could use large files, or you could
        use the -t option, and have the aggregate file data set size
        be larger than the amount of RAM in the server.

    5. Be wary of using -I  (Direct I/O) The problem is not
        in Iozone, but in the fact that there are many versions
        of Linux, and other Unixes, that do not actually honor
        the O_DIRECT, but also do not return errors when
        it is used.  For example: Some systems have:

        Example #1:  #define O_DIRECT
        Example #2:  #define O_DIRECT O_SYNC
        Example #3:  #define O_DIRECT O_RSYNC|O_SYNC

        None of the above are actually equivalent to a real
        Direct I/O method.

    6. Getting very tricky here:
        You might try using the -W option. This enables file locking.
        Not that you wanted file locking, but you might want its
        side effect. In many Unix systems, enabling file locking over
        NFS completely disables the NFS client caching, for
        reads, and writes :-) and does so for ALL file sizes.

Enjoy,
Don Capps

----- Original Message ----- 
From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Cc: "Jeff Blaine" <jblaine@mitre.org>; <nfs@lists.sourceforge.net>; 
<capps@iozone.org>
Sent: Saturday, January 29, 2005 4:48 AM
Subject: Re: [NFS] 2.4.21 NFSv3 performance graph


> OK so now I run with your recommanded options and I get Output perfs as 
> high as my network speed !! I am very surprised ! I don't think I am 
> measuring NFS perfs here but network speed :-( .
> Indeed for any couple filesize/record lenght I get wites result (see 
> sample below) around 11000Kbytes/sec -> so if I am right -> 11MB/s -> or 
> 88Mbits/s ~= my 100Mbits ethernet througput ! (less ethernet/ip overhead 
> !)
>
> here's what I did:
> $mount cobra3:/p2v5f3 /mnt/cobra3/ -o async,nfsvers=3
> [root@arvouin /mnt/cobra3/iozone/arvouin]
> $time iozone -a -c -e -i 0 -i 1 > arvouin-cobra3-i01-a-c-e.iozone
>
> Command line used: iozone -a -c -e -i 0 -i 1
>        Output is in Kbytes/sec
> Processor cache size set to 1024 Kbytes.
>        Processor cache line size set to 32 bytes.
>        File stride size set to 17 * record size.
>                                                            random  random 
> bkwd
> record  stride
>              KB  reclen   write rewrite    read    reread    read   write 
> read rewrite    read   fwrite frewrite   fread  freread
>            1024       4   10529   10603   409270   408936 
> 1024       8   10571   10666   472558   533076
> ....
>            262144      64   11146   11156    11230    11225 
> 262144     128   11152   11172    11228    10948
>
> here only read/reread changes as filesize increases , anyway 400/500MB/s 
> reads is well over my 12.5 theorical ethernet througput, I suspect cache 
> intervention here, no ? although I did put -e -c  options !
>
> Any comment , advices ? what kind of result do you get for NFS writings 
> with iozone ? as high as I get ? which options I am missing ?
>
> Thanks.
> Trond Myklebust wrote:
>
>>fr den 21.01.2005 Klokka 18:09 (+0100) skreiv Jehan PROCACCIA:
>>
>>>more generaly, what tool do you recommand to bench NFS ?
>>>I tried bonnie, bonnie++ and iozone.
>>>for the latest here's the kind of command I ran (so that it doesn't takes 
>>>hours to run the test!):
>>>/opt/iozone/bin/iozone -p -s 10k -s 100k -s 1m -s 5m -s 10m -s 100m -i 
>>>  -i 1 -r 4 -r 64 -r 256 -r 512 -r 1024 -r 4096 -r8192 -r 16384 -c -U 
>>>/mnt/cobra3 -f /mnt/cobra3/iozone.nagiostux > iozone-result
>>>
>>>My problem is that my NFS server has 4Go of ram, and bench programs 
>>>always recommand to use filesize for tests higher than RAM size and even 
>>>double size of the RAM so that it is not messuring cache activities !
>>>
>>
>>For tests of reading, this is undoubtedly true. For tests of writing
>>over NFS, this may be false: see the discussions of the iozone "-c" and
>>"-e" flags below.
>>
>>Note that bonnie and bonnie++ lack the equivalent of the "-e", "-c"
>>flags, and so are indeed not good for testing wire speeds unless you use
>>very large files.
>>
>>
>>>Can you give me a sample of the iozone arguments you used ?
>>>Any other tools ?
>>>
>>
>>It depends on what I want to test 8-)
>>
>>
>>Something like "iozone -c -a" should be fine for a basic test of the
>>generic read/write code functionality.
>>Note the "-c" which *is* usually necessary under NFS since any cached
>>writes are going to be flushed to disk by the "close()" (or when the
>>process exits). This means that close() will normally end up dominating
>>your write timings for files < memory size.
>>
>>If you want to test mmap(), something like "iozone -e -B -a". I believe
>>that "-e" should normally ensure that any writes are flushed to disk
>>using the fsync() command, and that this is timed.
>>Note that if you don't care about knowing how long it takes for the
>>writes to be flushed to disk then you can drop the "-e": unlike ordinary
>>read/write, mmap() does not guarantee that writes are flushed to disk
>>after the file is closed.
>>
>>For direct IO, "iozone -I -a" suffices. Since direct IO is uncached, all
>>write operations are synchronous, so "-c" and "-e" are unnecessary.
>>
>>
>>Cheers,
>>  Trond
>>
>
> 




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
