From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 19:52:31 +0100
Message-ID: <20100309185230.GX19154@ics.muni.cz>
References: <4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	<20100308194054.GC19154@ics.muni.cz>
	<20100308144825.0e1afa59@tlielax.poochiereds.net>
	<20100309103548.GJ19154@ics.muni.cz>
	<4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
	<20100309155310.GR19154@ics.muni.cz>
	<4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
	<20100309172908.GU19154@ics.muni.cz>
	<20100309174159.GW19154@ics.muni.cz>
	<4d569c331003091026r7e83523bwb8c448edf90441ed@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003091026r7e83523bwb8c448edf90441ed@mail.gmail.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 09, 2010 at 01:26:14PM -0500, Kevin Coffman wrote:
> Yes, but the utils/gssd/Makefile should link librpcsecgss and
> libgssglue before the Kerberos libs.

The Makefile does not link librpcsecgss and glue at all. So I put pkg-config
--libs librpcsecgss to the end.

So it seems to be the only bug, why my autotools do not set RPCSECLIBS and
RPCSECCFLAGS. (They are set empty.)

(I don't see any checking for RPCSECGSS or GSSGLUE messages as output of
./configure)

-- =

Luk=E1=B9 Hejtm=E1nek
