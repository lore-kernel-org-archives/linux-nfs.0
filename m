From: James Pearson <james-p@moving-picture.com>
Subject: Re: NFSv4 and client caching to local disk?
Date: Mon, 31 Mar 2003 13:33:39 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E8835A3.D5E64144@moving-picture.com>
References: <6440EA1A6AA1D5118C6900902745938E07D55473@black.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mpc-26.sohonet.co.uk ([193.203.82.251] helo=moving-picture.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18zyUh-00049N-00
	for <nfs@lists.sourceforge.net>; Mon, 31 Mar 2003 04:34:31 -0800
To: "Lever, Charles" <Charles.Lever@netapp.com>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

"Lever, Charles" wrote:
> 
> hi james-
> 
> > I'm trying to find out more about 'cachefs' type file systems
> > that can
> > cache NFS data to a client's local disk - I've come across a
> > couple of
> > references that seem to indicate that this may be possible with NFSv4.
> >
> > Does (will?) the Linux NFSv4 client support this feature?
> 
> Sun implemented cachefs on Solaris for earlier versions of NFS.
> it really has nothing to do with which version of NFS that is
> in use.

I've briefly looked at this on IRIX clients some time ago - but we don't
have many IRIX boxes in use now.
 
> there is sporadic interest in a cachefs on Linux, and i know of
> at least one generic prototype.  a specific implementation of
> client-side disk caching that is available today is contained
> in the Linux OpenAFS client (known as the AFS cache manager).

I have done some limited searching of the net for info and come across a
few attempts with earlier kernels - and I am aware of some the
issues/problems associated with doing this.
 
> cachefs becomes rather more interesting when used in conjunction
> with NFSv4 file delegations -- that makes NFS behave in a fashion
> similar to AFS client-side disk caching with callbacks.

My hopes were raised as the NFSv4 specs suggest that low level support
for client disk caches is available - rather than being a 'bolt-on' for
earlier versions - hence my question.
 
> there currently is no explicit plan to implement cachefs by the
> team that is working on NFSv4 for Linux.  a disk cache has
> rather limited usefulness compared to a memory cache.  what is
> your application for it?

Mainly for reading large files that don't change (much) - i.e.
effectively in a read-only mode. The total size of the required files is
greater than the clients memory size - in fact any disk caching of NFS
data doesn't necessarily need to survive a reboot of the client, so
caching NFS file system data to swap could be enough for my needs ...

James Pearson


-------------------------------------------------------
This SF.net email is sponsored by: ValueWeb: 
Dedicated Hosting for just $79/mo with 500 GB of bandwidth! 
No other company gives more support or power for your dedicated server
http://click.atdmt.com/AFF/go/sdnxxaff00300020aff/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
