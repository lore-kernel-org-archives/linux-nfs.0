From: "David B. Ritch" <dritch@hpti.com>
Subject: Re: Performance problem
Date: 13 May 2002 12:35:24 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1021307724.2651.3.camel@twitch>
References: <1021302616.27660.20.camel@nb>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sl-highp1-1-0.sprintlink.net ([144.228.5.138] helo=localhost.localdomain)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177InS-0005Gb-00
	for <nfs@lists.sourceforge.net>; Mon, 13 May 2002 09:35:39 -0700
To: Nicolas Brainez <nb@many.be>
In-Reply-To: <1021302616.27660.20.camel@nb>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Make sure that your server and clients agree on the MTU of the network. 
I don't recall having seen the request slot message associated with that
sort of problem, but an MTU problem can cause messages to be dropped.

Can you nfs-mount a partition exported from the server on the server
itself?  If so, can you copy on the nfs-mounted partition?  (Trying to
isolate the issue from the network)

David Ritch

On Mon, 2002-05-13 at 11:10, Nicolas Brainez wrote:
> Hello,
> 
> I have an nfs server who exports some backup directories for the lan's
> users, it's a new install.
> 
> First I would like say that's not an hardware problem, because we have
> no problem to use appletalk, ftp, ...
> 
> I can mount remotly a partition on the nfs server without problem but
> when I copy something on it, the client ('cp' in this case) hangs, and I
> receive these messages on my console :
> 
> nfs: task XXX can't get a request slot
> 
> where XXX is begin from 1 to...
> 
> When I look on the server, the file I was trying to copy is only 8192
> bytes :
> 
> -rwxr-xr-x    1 root     root         8192 May 13 16:56 bash
> 
> After looking web, newsgroup, etc.. I've tried all what I can do to
> optimize performance (wsize=8192,rsize=8192,hard/soft, etc.. etc..)
> 
> The only changes is when I use wsize and rsize to 8192, the file I sent
> to the server can goes to 16384 bytes, but never more..
> 
> This is a LAN of ~ 10 computers, 100mbps, and we use switchs.
> The servers and workstation use Debian woody, nfs kernel and user server
> tried, same results.
> 
> Any type of help is welcome.
> 
> Thanks.
> 
> --
> Nicolas Brainez
> 
> 
> _______________________________________________________________
> 
> Have big pipes? SourceForge.net is looking for download mirrors. We supply
> the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
