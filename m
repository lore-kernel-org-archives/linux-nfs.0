From: Emanuel Quass <emanuel.quass@temic.com>
Subject: Re: NFS & Clustering
Date: Wed, 4 Sep 2002 18:24:46 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209041824.46264.emanuel.quass@temic.com>
References: <95AF67BA7F70D511829B0002A551737001C9CB@faw-e01.faw.freudenberg.de> <1031155426.25370.2.camel@plokta.s8.com>
Reply-To: emanuel.quass@temic.com
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: "Bryan O'Sullivan" <bos@serpentine.com>
In-Reply-To: <1031155426.25370.2.camel@plokta.s8.com>
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

Hi,

but doesn't it work if you share /var/lib/nfs/* (containing etab, rmtab, =
sm, =20
sm.bak, state, xtab)?

MfG
=09Emanuel

Am Mittwoch, 4. September 2002 18:03 schrieb Bryan O'Sullivan:
> On Wed, 2002-09-04 at 01:35, Marco.Schwarz@Freudenberg.de wrote:
> > we are looking into the possibility of building a clustered NFS-root
> > server for our diskless clients. Does anybody know if this is possibl=
e
> > with NFS and which cluster software is best for this task (OpenMOSIX =
?).
>
> It isn't possible without a modified mountd that replicates mount
> information.  I haven't seen any free NFS servers that do this, but I
> haven't looked very hard.
>
> =09<b


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
