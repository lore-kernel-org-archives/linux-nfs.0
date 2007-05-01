From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: how to check if file locking is working?
Date: Tue, 01 May 2007 00:01:40 -0700
Message-ID: <1178002901.5588.11.camel@heimdal.trondhjem.org>
References: <46308D00.5040109@wpkg.org>  <463098C8.8010900@wpkg.org>
	<1177882063.6400.39.camel@heimdal.trondhjem.org>
	<4636DD23.2000509@wpkg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tomasz Chmielewski <mangoo@wpkg.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HimKw-0006fD-CG
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 23:59:46 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18ma2QiGanrSdFmZG9CUqfNt+GlT475uhs=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HimKx-0001Dk-IN
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 23:59:49 -0700
In-Reply-To: <4636DD23.2000509@wpkg.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, 2007-05-01 at 08:24 +0200, Tomasz Chmielewski wrote:
> Trond Myklebust schrieb:
> > On Thu, 2007-04-26 at 14:19 +0200, Tomasz Chmielewski wrote:
> >> Tomasz Chmielewski wrote:
> >>> How can I check if file locking is working?
> >>>
> >>> I have a NFS4 server (Linux x86) and a NFS4 client (Linux ARM).
> >>>
> >>>
> >>> NFS4 server exports a Debian-ARM root filesystem (/bin, /etc, /usr... a 
> >>> complete OS).
> >>>
> >>> I want to "upgrade" the Debian-ARM root filesystem in a NFS4 chroot, but 
> >>> it fails - dpkg claims that:
> >>>
> >>> debconf: DbDriver "config": /var/cache/debconf/config.dat is locked by 
> >>> another process
> >>>
> >>> It's not true, as that export is only used by that one client.
> >>>
> >>> So what comes to my mind, is that file locking is somehow broken.
> >>>
> >>> How can I check if NFS4 file locking works properly, or is broken?
> >> I changed the client to use NFSv3 instead of NFSv4, and suddenly, the 
> >> things started to work...
> >>
> >> Ideas what I might be missing? Why locking works if I use NFSv3 on the 
> >> client, but doesn't when I use NFSv4 on the client (other than NFS 
> >> version, nothing else changed).
> >>
> >> Kernel option on a client or server, export options on the server, mount 
> >> options on the client etc.?
> > 
> > nfsroot does not support NFSv4 at this time.
> 
> Hmm, I didn't say anything about nfsroot, did I?
> 
> I merely did a chroot over NFSv4, and some apps don't work well then.

Sorry. I misread your mail. The easiest way to check basic locking would
be to run the connectathon suite. See
http://www.connectathon.org/#technologies

Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
