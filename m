From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Sat, 29 Jan 2005 11:48:48 +0100
Message-ID: <41FB6A10.6000001@int-evry.fr>
References: <41E816B3.4030702@mitre.org>	 <1105747170.28849.22.camel@lade.trondhjem.org>	 <41F13749.4090900@int-evry.fr> <1106329537.9849.68.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Blaine <jblaine@mitre.org>, nfs@lists.sourceforge.net,
	capps@iozone.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cuuro-00020T-38
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 07:50:32 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cuurn-0000xJ-50
	for nfs@lists.sourceforge.net; Sat, 29 Jan 2005 07:50:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1106329537.9849.68.camel@lade.trondhjem.org>
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

OK so now I run with your recommanded options and I get Output perfs as 
high as my network speed !! I am very surprised ! I don't think I am 
measuring NFS perfs here but network speed :-( .
Indeed for any couple filesize/record lenght I get wites result (see 
sample below) around 11000Kbytes/sec -> so if I am right -> 11MB/s -> or 
88Mbits/s ~= my 100Mbits ethernet througput ! (less ethernet/ip overhead !)

here's what I did:
$mount cobra3:/p2v5f3 /mnt/cobra3/ -o async,nfsvers=3
[root@arvouin /mnt/cobra3/iozone/arvouin]
$time iozone -a -c -e -i 0 -i 1 > arvouin-cobra3-i01-a-c-e.iozone

Command line used: iozone -a -c -e -i 0 -i 1
        Output is in Kbytes/sec
Processor cache size set to 1024 Kbytes.
        Processor cache line size set to 32 bytes.
        File stride size set to 17 * record size.
                                                            random  
random    bkwd
record  stride
              KB  reclen   write rewrite    read    reread    read   
write    read rewrite    read   fwrite frewrite   fread  freread
            1024       4   10529   10603   409270   
408936                                           
            1024       8   10571   10666   472558   533076
....
            262144      64   11146   11156    11230    
11225                                            
            262144     128   11152   11172    11228    10948

here only read/reread changes as filesize increases , anyway 400/500MB/s 
reads is well over my 12.5 theorical ethernet througput, I suspect cache 
intervention here, no ? although I did put -e -c  options !

Any comment , advices ? what kind of result do you get for NFS writings 
with iozone ? as high as I get ? which options I am missing ?

Thanks. 

Trond Myklebust wrote:

>fr den 21.01.2005 Klokka 18:09 (+0100) skreiv Jehan PROCACCIA:
>  
>
>>more generaly, what tool do you recommand to bench NFS ?
>>I tried bonnie, bonnie++ and iozone.
>>for the latest here's the kind of command I ran (so that it doesn't 
>>takes hours to run the test!):
>>/opt/iozone/bin/iozone -p -s 10k -s 100k -s 1m -s 5m -s 10m -s 100m -i 
>>0  -i 1 -r 4 -r 64 -r 256 -r 512 -r 1024 -r 4096 -r8192 -r 16384 -c -U 
>>/mnt/cobra3 -f /mnt/cobra3/iozone.nagiostux > iozone-result
>>
>>My problem is that my NFS server has 4Go of ram, and bench programs 
>>always recommand to use filesize for tests higher than RAM size and even 
>>double size of the RAM so that it is not messuring cache activities !
>>    
>>
>
>For tests of reading, this is undoubtedly true. For tests of writing
>over NFS, this may be false: see the discussions of the iozone "-c" and
>"-e" flags below.
>
>Note that bonnie and bonnie++ lack the equivalent of the "-e", "-c"
>flags, and so are indeed not good for testing wire speeds unless you use
>very large files.
>
>  
>
>>Can you give me a sample of the iozone arguments you used ?
>>Any other tools ?
>>    
>>
>
>It depends on what I want to test 8-)
>
>
>Something like "iozone -c -a" should be fine for a basic test of the
>generic read/write code functionality.
>Note the "-c" which *is* usually necessary under NFS since any cached
>writes are going to be flushed to disk by the "close()" (or when the
>process exits). This means that close() will normally end up dominating
>your write timings for files < memory size.
>
>If you want to test mmap(), something like "iozone -e -B -a". I believe
>that "-e" should normally ensure that any writes are flushed to disk
>using the fsync() command, and that this is timed.
>Note that if you don't care about knowing how long it takes for the
>writes to be flushed to disk then you can drop the "-e": unlike ordinary
>read/write, mmap() does not guarantee that writes are flushed to disk
>after the file is closed.
>
>For direct IO, "iozone -I -a" suffices. Since direct IO is uncached, all
>write operations are synchronous, so "-c" and "-e" are unnecessary.
>
>
>Cheers,
>  Trond
>  
>



-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
