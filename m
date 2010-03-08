From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 20:40:54 +0100
Message-ID: <20100308194054.GC19154@ics.muni.cz>
References: <4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	<4B903485.1030608@oracle.com> <20100304224011.GN19154@ics.muni.cz>
	<20100308101607.GR19154@ics.muni.cz>
	<20100308070209.7cabb55f@tlielax.poochiereds.net>
	<20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	<20100308153042.GB19154@ics.muni.cz>
	<4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
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

On Mon, Mar 08, 2010 at 02:21:57PM -0500, Kevin Coffman wrote:
> So you probably need to add "allow_weak_crypto =3D true" to your
> /etc/krb5.conf file.  (I believe MIT added an API to allow this
> programmatically, but I haven't been following closely enough.)

well, this one fixes problem with nfs-utils-1.2.0.

The 1.2.2 still segfaults. Any other thoughts or should I start to play bis=
ect
game?

-- =

Luk=E1=B9 Hejtm=E1nek
