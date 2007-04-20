From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
 on a privileged port??
Date: Fri, 20 Apr 2007 15:18:36 -0400
Message-ID: <4629120C.60803@RedHat.com>
References: <17958.48121.280256.493824@notabene.brown>	<20070419012154.GB19063@javifsp.no-ip.org>
	<17960.11704.321124.641669@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Matthias Koenig <mkoenig@novell.com>, nfs@lists.sourceforge.net,
	Olaf Kirch <olaf.kirch@oracle.com>,
	=?ISO-8859-1?Q?Javier_Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>,
	anibal@debian.org
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Heydz-00054q-Kz
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 12:19:43 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Heye1-00058b-UZ
	for nfs@lists.sourceforge.net; Fri, 20 Apr 2007 12:19:46 -0700
In-Reply-To: <17960.11704.321124.641669@notabene.brown>
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



Neil Brown wrote:
> Well, the consensus seems to be that a new 'upstream' would not be a
> bad thing, but that including it in nfs-utils might not be the best
> idea.
> 
> I can live with that, and would like to nominate myself as the new
> upstream source for 'portmap'.  Does anyone object?
> 
> I have created a git repository that can be accessed via:
>    git://neil.brown.name/portmap
> or
>    http://neil.brown.name/git?p=portmap  (for browsing).
Is there any particular reason your staying with portmap
instead of moving on to rpcbind? Rpcbind supports portmap
functionality as well has IPv6 support and warm starts
support (meaning it saves state so services don't have to
re-register if the rpcbind is restarted).

Another nice benny is, rpcbind used the libtirpc library
which is a stand alone lib... meaning we no longer need
to depend on the RPC code in glibc... which I think is
HUGE... is basically the main reason (other than IPv6
support) I'm pushing Fedora Core in that direction...
Braveheart said it best: FREEDOM [from the glibc code]!!! :-D

I (hastily) created two git trees:
git://git.infradead.org/~steved/libtirpc.git
git://git.infradead.org/~steved/rpcbind.git

I think if you take a look, you'll see that
this code may not be as mature as the portmap
code, but its a much better start... imho..


> There are two patches from Fedora that I have not included.
> 
> One uses 'getpwnam("rpc")' to find a uid to 'setuid' to.
> This could be a problem is NIS is in use and 'rpc' isn't in
> /etc/passwd - portmap would be need to find the NIS server to check
> for 'rpc' before portmap could start.
We ensure the rpc uid/gid is created when we install the rpm,
but yes if nis is tried before /etc/passwd this will hang but
we've never come across such an occurrence (yet :-\ )


steved.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
