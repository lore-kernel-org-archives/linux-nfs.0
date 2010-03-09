From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 18:41:59 +0100
Message-ID: <20100309174159.GW19154@ics.muni.cz>
References: <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	<20100308153042.GB19154@ics.muni.cz>
	<4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	<20100308194054.GC19154@ics.muni.cz>
	<20100308144825.0e1afa59@tlielax.poochiereds.net>
	<20100309103548.GJ19154@ics.muni.cz>
	<4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
	<20100309155310.GR19154@ics.muni.cz>
	<4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
	<20100309172908.GU19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100309172908.GU19154@ics.muni.cz>
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

On Tue, Mar 09, 2010 at 06:29:08PM +0100, Lukas Hejtmanek wrote:
> But I found the problem. They are still autotools which are failing. Some=
thing
> adds -lgssapi_krb5 into KRBLIBS. If I remove -lgssapi_krb5 and use -lgssg=
lue
> instead, it runs fine.

this seems to be caused by configure, which contains:
KRBLIBS=3D`$K5CONFIG --libs gssapi`

$ krb5-config --libs gssapi
-Wl,-Bsymbolic-functions -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err

./aclocal/kerberos5.m4 contains as well:
KRBLIBS=3D`$K5CONFIG --libs gssapi`

-- =

Luk=E1=B9 Hejtm=E1nek
