From: "Iozone" <capps@iozone.org>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Thu, 17 Feb 2005 11:57:20 -0600
Message-ID: <14eb01c5151a$20b0ae30$1500000a@americas.hpqcorp.net>
References: <41E816B3.4030702@mitre.org>	 <1105747170.28849.22.camel@lade.trondhjem.org>	 <41F13749.4090900@int-evry.fr> <1106329537.9849.68.camel@lade.trondhjem.org> <41FB6A10.6000001@int-evry.fr> <006701c50627$81122b70$06000800@americas.hpqcorp.net> <41FCC5FF.6030703@int-evry.fr> <4214A200.3040206@int-evry.fr> <148901c51507$90f5a820$1500000a@americas.hpqcorp.net> <4214D406.2070404@int-evry.fr>
Reply-To: "Iozone" <capps@iozone.org>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="iso-8859-1";
	reply-type=response
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Jeff Blaine" <jblaine@mitre.org>, <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1pu2-0001wJ-Pq
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 09:57:26 -0800
Received: from out008pub.verizon.net ([206.46.170.108] helo=out008.verizon.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1pu2-0007Sd-5U
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 09:57:26 -0800
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

    Comments below:

----- Original Message ----- 
From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
To: "Iozone" <capps@iozone.org>
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>; "Jeff Blaine" 
<jblaine@mitre.org>; <nfs@lists.sourceforge.net>
Sent: Thursday, February 17, 2005 11:27 AM
Subject: Re: [NFS] 2.4.21 NFSv3 performance graph


>>
>>        I noticed on your web page that you boiled the
>>    3D surface data down to a single value, and picked
>>    the highest value for this number. Ok... that's
>>    funky and pretty much meaningless.
>
>
> Yes , I did that on purpose to have a single value of comparition with 
> bonnie++ tests, see the beware paragraph in the 13.1.4 section . But 
> indedd I must adit it is pretty much meaningless !.

    If you want to compare a single value from Iozone with Bonnie then
    you need to run Iozone and Bonnie with the same file size, and
    since you seem to want physical I/O, use a file size that is
    larger than the amount of RAM in the NFS client.
    With that done, you should get 11 Mbytes/sec on both
    tests, as you are 100Mbit limited.  Again, not terribly revealing
    but at least both tests were run under similar conditions.

>
>>   If you must reduce the
>>    data down to a single  value, you'll have to pick what you
>>    want to represent.
>>
>>    (Client side cache performance, or NFS server performance)
>>
>>    and pick the value from the appropriate region on the
>>    surface of the plot.  Left side is the client cache, right side
>>    is NFS server.
>
> the thing is that the slope of the surface (not sure of my english here 
> ...)

        Your English is far better than my French :-)

> is rather climbing from left to right in writes tests, and droping from 
> left to right in read tests !
> exemple : 
> http://www.int-evry.fr/s2ia/user/procacci/Doc/NFS/Aa-C2s/write/write.png
> so when the client cache is overfull I get better write performances .. ? 
> surprising !?.
>
> http://www.int-evry.fr/s2ia/user/procacci/Doc/NFS/Aa-C2s/read/read.png
> here in reads, when the cache is overfull I get lower read performances 
> with a signyficative break at the 128MB file size ! Here I find this to be 
> logical .

    Look at the Y axis scale.  The Writer is scaled to 12 Mbytes/sec. The
    Reader is scaled to 700 Mbytes/sec.  For the writer, the larger
    files and larger transfers do better as there is less system call 
overhead
    and more work being done on each NFS request.  This continues
    until you become network limited.

    For the Reader, the client side cache dominates, until the file size
    exceeds the cache. At that point you become network limited
    and obtain basically the same result as the writer.

>
>> The cross over is where the file size
>>    no longer fits in the client side cache. Also, you'll need
>>    to document which thing you are measuring.
>
> Actually I want to measure the whole NFS performance, for daily users 
> usage,  from client to server reponses, isn't it why I did ?

    By using a range of file sizes and tranfer sizes and plotting
    the 3D graph, you indeed represent the complete NFS performance
    of the NFS client and server.  So... single values (Bonnie, or Iozone)
    do not fully represent the entire picture. Thus, why Iozone does
    ranges instead of points :-)

    Hint: Although one can use Gnuplot, the Excel graphs show
            more detail and are much easier to interpret.

Enjoy,
Don Capps




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
