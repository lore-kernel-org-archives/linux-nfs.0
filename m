From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Help diagnosing bizarre NFS problem
Date: Thu, 13 Jan 2005 23:34:11 -0500
Message-ID: <1105677251.20314.26.camel@lade.trondhjem.org>
References: <BA594DD2-65DA-11D9-B0EB-000A95A07AB8@valuecommerce.co.jp>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpJAJ-000327-HZ
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 20:34:27 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CpJAH-0007X1-S8
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 20:34:27 -0800
To: Nathan Ollerenshaw <nathan@valuecommerce.co.jp>
In-Reply-To: <BA594DD2-65DA-11D9-B0EB-000A95A07AB8@valuecommerce.co.jp>
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

fr den 14.01.2005 Klokka 12:16 (+0900) skreiv Nathan Ollerenshaw:

> Sometimes we will see a message like this:
> 
> Dec 27 10:41:51 www2 kernel: nfs_statfs: statfs error = 512

This probably just indicates that someone pressed ^C in order to break
out of a hanging RPC call.

> Messages such as this are also common:
> 
> nfs_proc_symlink: lock/DGMDNP-042.txt_lock_lock already exists??

This too is relatively harmless. It means that the server replied that
the symlink exists. It is either a sign that the server RPC replay cache
is full (this would be infrequent on a normal server), or that you have
an application that is running on 2 clients and that is racing to create
the same symlink.

> Doing a tethereal at the time, we see stuff like this:
> 
>   62.303877  10.128.1.11 -> 10.128.2.33  NFS V3 WRITE Reply (Call In 27) 
> Error:ERR_STALE

Now this is not normal, unless someone is going around on the server
maliciously deleting files that are still in use by the client.

It shouldn't be causing any hangs though (either on the client or the
server).

> Vendor currently says:
> 
> > Anyway, at the present moment, we can say, we haven't finished 
> > analyzing
> > network traces completely, however, we found some strange point in the
> > network trace. As per customer, customer uses the file locking over 
> > NFS.
> > Indeed, we can see NLM protocol in the network trace. Some of  clients 
> > keep
> > sending NLM_UNLOCK for some of files without sending NLM_LOCK. 
> > Generally, if
> > using NLM, the sequence is NLM_LOCK call for relevant file is executed 
> > from
> > NFS client and then NLM_UNLOCK for that file is executed from NFS 
> > client.
> > Thus, the file locking will be completed. We can't see any corresponds
> > between LOCK and UNLOCK. From the beginning of the trace, some of 
> > client
> > keep sending only NLM_UNLOCK. That is very strange.

That is deliberate. If someone presses ^C while the client is in the
middle of sending an NLM_LOCK request, then the client has no way of
knowing whether or not the server received that request. The safe thing
to do then is to always assume that the server has received the request,
and to send a corresponding NLM_UNLOCK request.

That way you avoid creating "orphaned locks" on the server.

---

A shot in the dark: are you perhaps using TCP together with an old
version of amd/am-utils? It used to be the case that am-utils would set
a very short value for the RPC timeout value (see the description of the
"timeo" mount option on "man 5 nfs"). I know several cases of this
overloading the server and causing strange hangs.
That would explain the above symlink error message in terms of the RPC
replay cache hypothesis...

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
