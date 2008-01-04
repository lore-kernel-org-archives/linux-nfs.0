From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RE: A new NFSv4 server...
Date: Fri, 4 Jan 2008 12:31:03 -0800
Message-ID: <01AE8AF878612047A442668306EAEB05016D509C@SACEXMV01.hq.netapp.com>
References: <477CD231.30603@garzik.org>
	<20080103163200.GB30029@fieldses.org><477DC501.3060104@garzik.org>
	<477DD11B.40909@melbourne.sgi.com><477DDA86.6020100@garzik.org>
	<Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFS list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>,
	"Jeff Garzik" <jeff@garzik.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-reply-to: <Pine.LNX.4.64.0801040954070.5004@maggie.lkpg.cendio.se>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

I like it.  NFS 3.5.  Drop pNFS into the v3 protocol (a greatly simplified =
pNFS compared to what we ended up with in 4.1), and you'd have yourself a s=
weet little distributed fs.  The important part is that any such effort be =
called "NFS x.y".  Naming is important, or we'd be running AFS/DFS instead =
of NFS 4.0 (please, try to resist flaming me on the hyperbole).

  -Dan

-----Original Message-----
From: Peter =C5strand [mailto:astrand@cendio.se] =

Sent: Friday, January 04, 2008 1:15 AM
To: Jeff Garzik
Cc: NFS list; nfsv4@linux-nfs.org
Subject: Re: A new NFSv4 server...


[About v4]


On Fri, 4 Jan 2008, Jeff Garzik wrote:

> > > I really wish the entire wire protocol were scrapped and replaced =

> > > with something more sane, and easier to parse.
> > You had me worried there for a moment, I thought you might be the =

> > first person to admit to liking the NFS4 protocol design.

Couldn't agree more. =




> In my personal opinion, version 4 of NFS is a quantum-leap improvement =

> over previous versions.  While I used NFS v3 extensively, I always =

> felt it was a crappy protocol, and unworthy of serious development =

> effort. That changed with v4.
...
> > > It's tempting to see what would arise from a clean-slate wire =

> > > protocol effort, something that is otherwise compatible with NFS =

> > > 4.x operations, objects, and data model.
> =

> It's more like v4 is a vast relative improvement over prior NFS.  =

> Given the huge number of NFS users and sites, IMO v4 is a huge =

> improvement for Unix file sharing overall.

Many years ago, before NFSv4 was finished, I felt the same. I was waiting f=
or v4 and thought that everything would be so much better. I wanted to help=
 and started the "pynfs" project. Today, I have a different opinion. I thin=
k v3 is a fairly good protocol, if you use it correctly. For example, many =
people don't realize that you don't need the portmapper, that you can use a=
 single well-known TCP port, that you can use RPCSEC_GSS and so forth, even=
 with v3. =



I think v4 has a few valuable improvements, but it comes with a very high p=
rice. v3 has a minimalistic beauty which v4 lacks. For example, take a look=
 at the OPEN operation with 7 arguments, of which many are complex data str=
uctures:

    (cfh), seqid, share_access, share_deny, owner, openhow, claim ->
    (cfh), stateid, cinfo, rflags, open_confirm, attrset delegation

Not pretty...  =




> Oh, certainly.  I was mainly thinking a replacement of the wire =

> protocol would be an easier step for people to swallow than a new protoco=
l.

I've been thinking of trying to put together something like NFS v3.5. Some =
parts of v4 are nice, but the complexity is too high. =



Regards, =

---
Peter =C5strand		ThinLinc Chief Developer
Cendio AB		http://www.cendio.se
Wallenbergs gata 4
583 30 Link=F6ping	Phone: +46-13-21 46 00
