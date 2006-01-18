From: "Wally Winchester" <wally_winchester@fastmail.fm>
Subject: Re: Stale nfs file handle - cwd without path - workaround?
Date: Wed, 18 Jan 2006 08:43:39 +0000
Message-ID: <1137573819.15439.252122025@webmail.messagingengine.com>
References: <1137402966.3299.251938119@webmail.messagingengine.com>
   <200601170043.18048.bernd-schubert@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ez8uv-0004HY-Sj
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 00:43:45 -0800
Received: from out4.smtp.messagingengine.com ([66.111.4.28])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Ez8uu-0000no-Nm
	for nfs@lists.sourceforge.net; Wed, 18 Jan 2006 00:43:46 -0800
To: "Bernd Schubert" <bernd-schubert@gmx.de>,
	nfs@lists.sourceforge.net
In-Reply-To: <200601170043.18048.bernd-schubert@gmx.de>
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


On Tue, 17 Jan 2006 00:43:17 +0100, "Bernd Schubert"
<bernd-schubert@gmx.de> said:
> Hello Wally,
> 
> > When nfs1 dies, and nfs2 takes over, everything works - as long as the
> > clients are writing files using the full paths.
> > If the path is omitted, i.e. they are expecting a write to their cwd, a
> > "stale nfs file handle" warning is issued.
> >
> > Is there a way around this?
> >
> > e.g. this works
> > touch /nfs-mount/file
> > (failover)
> > touch /nfs-mount/file
> >
> > e.g. this doesn't work
> > cd /nfs-mount/
> > touch file
> > (failover)
> > touch file
> > (stale nfs file handle)
> 
> really strange, we never had this problem. I think you have to provide
> some 
> more information (/etc/exports of both servers, kernel version,
> distribution, 
> how you handle /var/lib/nfs, drbd? configuration, etc.).
> 
> Cheers,
> 	Bernd
> 
> 
> 

As a follow up to my reply,
can anyone suggest how to troubleshoot this? Is there a way of getting
an nfs client to not cache the details of the cwd (if this is the
problem)?

I hope someone knows!
-- 
  Wally Winchester
  wally_winchester@fastmail.fm

-- 
http://www.fastmail.fm - Accessible with your email software
                          or over the web



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
