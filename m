From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Tue, 9 Mar 2010 18:29:08 +0100
Message-ID: <20100309172908.GU19154@ics.muni.cz>
References: <20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	<20100308153042.GB19154@ics.muni.cz>
	<4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	<20100308194054.GC19154@ics.muni.cz>
	<20100308144825.0e1afa59@tlielax.poochiereds.net>
	<20100309103548.GJ19154@ics.muni.cz>
	<4d569c331003090718j6cde9853o6142b2fd2900248e@mail.gmail.com>
	<20100309155310.GR19154@ics.muni.cz>
	<4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003090904i3eca4b93h1bce760e72bac370@mail.gmail.com>
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

On Tue, Mar 09, 2010 at 12:04:29PM -0500, Kevin Coffman wrote:
> I'm confused.  gssd shouldn't be calling any of the Kerberos GSS
> functions directly, it should be calling the one in libgssglue, which
> should call the mechanism-specific (Kerberos) version.

strange, but kerberos lib contains the name as well:
nm libgssapi_krb5.so  | grep gss_acquire_cred
000000000000b3a0 T gss_acquire_cred

nm libgssglue.so  | grep gss_acquire
00000000000004d0 T gss_acquire_cred

both are linked with gssd. So the linker probably picks one.

But I found the problem. They are still autotools which are failing. Someth=
ing
adds -lgssapi_krb5 into KRBLIBS. If I remove -lgssapi_krb5 and use -lgssglue
instead, it runs fine.

-- =

Luk=E1=B9 Hejtm=E1nek
