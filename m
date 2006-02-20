From: Bernd Strieder <strieder@informatik.uni-kl.de>
Subject: Re: NFS mount in a changing network
Date: Mon, 20 Feb 2006 10:49:00 +0100
Message-ID: <200602201049.00351.strieder@informatik.uni-kl.de>
References: <200602151716.18601.strieder@informatik.uni-kl.de> <200602161116.24884.strieder@informatik.uni-kl.de> <1140192487.3612.23.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FB7gS-0004Z3-Sw
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 01:50:20 -0800
Received: from mailgate1.uni-kl.de ([131.246.120.5])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FB7gR-0006aN-Cl
	for nfs@lists.sourceforge.net; Mon, 20 Feb 2006 01:50:21 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
In-Reply-To: <1140192487.3612.23.camel@lade.trondhjem.org>
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

Hello,

Am Freitag, 17. Februar 2006 17:08 schrieben Sie:
> On Thu, 2006-02-16 at 11:16 +0100, Bernd Strieder wrote:
> > The ultimate question, which might be helpful to others, which
> > I haven't found anything written on anywhere is:
> >
> > What are the things to care about, if you want to switch the
> > network configuration of a NFS server and a NFS client if
> > umount must be avoided? Are there any chances to get this
> > cleanly done?
>
> The basic rule of thumb follows directly from 1:
>
>         If you have clients that have mounted a given partition,
> then do _not_ bring up the server until you have set up all the
> exports.

IOW, if the server comes up, and has not the exports a running 
client expects, then the file handles on the client will get 
stale, and will not block until the server has the expected 
exports again. So there is no safety net in that respect, which I 
would prefer, if I had the choice. Many applications will not get 
into a non-recoverable state, when blocked, but ESTALE is 
different. I don't yet know whether closing the stale file-handle 
is possible, so this handling is not nice to do. 

>
> IOW: if you want to move the clients from one server to another,
> then the sequence is
>
>  1) Kill nfsd on _both_ servers
>  2) Move the IP address from server 1 to server 2
>  3) Add the exports for the clients from server 1 to
> /etc/exports on server 2 (and possibly run exportfs)
>  4) Now bring nfsd up on server 2.

I did not exactly move the server, but added additional IP 
addresses of a different network to the server.

I cannot remember the exact sequence of things I did, but I added 
export entries a few days before the main IP addresses changed, 
and I verified that I could mount using both IP addresses of the 
server, and I was happy, because it meant that I could possibly do 
the change without killing that process on the client.

I used private addresses before, and used another private network 
to try it out. I was not conscious that a missing export entry 
will make the client stale, I did not experience any problems like 
that during testing, probably because I did it right then. But in 
the end it is highly possible that I really missed some export 
entries at prime time. I need not tell you.

Thanks a lot,

Bernd Strieder


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
