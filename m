From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 16:53:10 +0100
Message-ID: <20100309155310.GR19154@ics.muni.cz>
References: <20100308101607.GR19154@ics.muni.cz>
	<20100308070209.7cabb55f@tlielax.poochiereds.net>
	<20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	<20100308153042.GB19154@ics.muni.cz>
	<4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	<20100308194054.GC19154@ics.muni.cz>
	<20100308144825.0e1afa59@tlielax.poochiereds.net>
	<20100309103548.GJ19154@ics.muni.cz>
	<4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
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

On Tue, Mar 09, 2010 at 10:18:58AM -0500, Kevin Coffman wrote:
> I've built nfs-utils with and without  --disable-tirpc and don't see
> this problem.
> =

> It could be a bug, but I would think that other [Debian and other]
> testers would have already hit it.
> =

> I'm concerned that perhaps your build issues may have somehow
> introduced a [bad] mix of headers?  (i.e. were things built using the
> libgssglue headers, or the Kerberos headers?)

I have both. If I remove gssglue headers, it still faults. If I remove
kerberos headers, it does not even compile.

I believe, that it has the following problem.

gssd calls gss_acquire_cred, it calls the one from libgssapi_krb5.so.2. =

This gss_acquire_cred filss in gss_union_cred_t structure. =

gssd calls gss_set_allowable_enctypes which is located in libgss_glue.
The libgssglue uses gss_union_cred_t structure.

This happens in limit_krb5_enctypes() in krb5_util.c

Unfortunately, gss_union_cred_t in libgssglue is missing one (first) item
compared to libgssapi_krb5.so.2, thus count is stored instead of mechs_arra=
y.
The mechs_array contains value 1 as I have shown. Dereferrencing means
segfault. =


Btw, do you have HAVE_SET_ALLOWABLE_ENCTYPES ?

-- =

Luk=E1=B9 Hejtm=E1nek
