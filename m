From: Jehan PROCACCIA <Jehan.Procaccia@int-evry.fr>
Subject: Re: 2.4.21 NFSv3 performance graph
Date: Fri, 21 Jan 2005 18:09:29 +0100
Message-ID: <41F13749.4090900@int-evry.fr>
References: <41E816B3.4030702@mitre.org> <1105747170.28849.22.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jeff Blaine <jblaine@mitre.org>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cs2I3-0000TC-2J
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:09:43 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cs2I0-0001gS-B5
	for nfs@lists.sourceforge.net; Fri, 21 Jan 2005 09:09:42 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1105747170.28849.22.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>fr den 14.01.2005 Klokka 14:00 (-0500) skreiv Jeff Blaine:
>  
>
>>Can anyone tell me what is happening in the graph at the URL
>>below?  I can replicate it on any Linux box running 2.4.21
>>and changing rsize/wsize doesn't affect it at all.  This
>>was captured from a 2.6GHz P4 client machine.  Same thing
>>is visible with a Dual 3GHz Xeon box with 4GB memory as a
>>client.  A Solaris 9 client does not display this "falling
>>on face" behavior.
>>
>>http://www.kickflop.net/temp/sol9-server-linux2421-client-gigE-ag930m_10533_image001.gif
>>    
>>
>
>Firstly, you should always use the '-c' flag when measuring NFS client
>performance. Otherwise, you are basically just measuring the speed with
>which your machine can write to the local page cache (which may indeed
>explain your "knee" at 1MB here - that would be where the client starts
>to force a flush to disk).
>
>Secondly, have you actually read the NFS FAQ and NFS HOWTO entries on
>how to tune for performance? Particularly the entries on TCP vs. UDP,
>and how Solaris clients default to the former.
>
>  Trond
>  
>
Hello,

more generaly, what tool do you recommand to bench NFS ?
I tried bonnie, bonnie++ and iozone.
for the latest here's the kind of command I ran (so that it doesn't 
takes hours to run the test!):
/opt/iozone/bin/iozone -p -s 10k -s 100k -s 1m -s 5m -s 10m -s 100m -i 
0  -i 1 -r 4 -r 64 -r 256 -r 512 -r 1024 -r 4096 -r8192 -r 16384 -c -U 
/mnt/cobra3 -f /mnt/cobra3/iozone.nagiostux > iozone-result

My problem is that my NFS server has 4Go of ram, and bench programs 
always recommand to use filesize for tests higher than RAM size and even 
double size of the RAM so that it is not messuring cache activities !

Can you give me a sample of the iozone arguments you used ?
Any other tools ?

thanks.


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
