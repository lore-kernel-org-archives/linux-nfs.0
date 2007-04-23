From: Neil Brown <neilb@suse.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Mon, 23 Apr 2007 14:03:48 +1000
Message-ID: <17964.12324.307985.65596@notabene.brown>
References: <17958.48121.280256.493824@notabene.brown>
	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
	<4629120C.60803@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Steve Dickson <SteveD@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hfpma-0004YS-PU
	for nfs@lists.sourceforge.net; Sun, 22 Apr 2007 21:04:08 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hfpmc-00042y-S5
	for nfs@lists.sourceforge.net; Sun, 22 Apr 2007 21:04:11 -0700
In-Reply-To: message from Steve Dickson on Friday April 20
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

On Friday April 20, SteveD@redhat.com wrote:
> Is there any particular reason your staying with portmap
> instead of moving on to rpcbind? 

I want distros to include the functionality I want (non-priv users
cannot remove registrations of non-priv ports registered by priv
users).  Given the two approaches:
   - please use newer version of portmap
   - please dump portmap and use rpcbind
I suspect the former to be more effective.

I'm not against moving to rpcbind, it is probably a very good idea.
But I expect there to be more resistance.
If everyone goes to rpcbind and no-one uses 'my' portmap, that would
be fine with me.

> 
> I (hastily) created two git trees:
> git://git.infradead.org/~steved/libtirpc.git
> git://git.infradead.org/~steved/rpcbind.git
> 
> I think if you take a look, you'll see that
> this code may not be as mature as the portmap
> code, but its a much better start... imho..

Yes, very hasty.  Several #temporary# and back~ files :-)

I notice that it has a concept of who 'owns' a registration, but it
only works if unix-domain sockets are used for the registration.
Adding 'superuser' ownership for localhost/privport registrations is
probably a 3 line patch....

So: yes.  Full steam ahead on rpcbind.  But short-term I think it is a
good idea to give portmap a little more life.

> 
> 
> > There are two patches from Fedora that I have not included.
> > 
> > One uses 'getpwnam("rpc")' to find a uid to 'setuid' to.
> > This could be a problem is NIS is in use and 'rpc' isn't in
> > /etc/passwd - portmap would be need to find the NIS server to check
> > for 'rpc' before portmap could start.
> We ensure the rpc uid/gid is created when we install the rpm,
> but yes if nis is tried before /etc/passwd this will hang but
> we've never come across such an occurrence (yet :-\ )

I wouldn't expect you to.  But another distro that doesn't create the
right uid/gid might hit it.
I think I'll add -u/-g flags
I might even include the Redhat code in #ifdef, so if compile with
 make RPCUSER=rpc
it will do the getpwnam..

Thanks,
NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
