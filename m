From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 16:30:42 +0100
Message-ID: <20100308153042.GB19154@ics.muni.cz>
References: <4B7D4E55.4040002@RedHat.com> <20100304201941.GL19154@ics.muni.cz>
	<4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	<4B903485.1030608@oracle.com> <20100304224011.GN19154@ics.muni.cz>
	<20100308101607.GR19154@ics.muni.cz>
	<20100308070209.7cabb55f@tlielax.poochiereds.net>
	<20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
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

On Mon, Mar 08, 2010 at 08:44:07AM -0500, Kevin Coffman wrote:
> I don't know how much testing has been done with nfs-utils and krb5
> 1.8.  Debian is usually the first to hit (and correct) any problems.
> Is there a later kerberos release you could try?  The final version of
> krb5 1.8 was released last week.

looks like some error check has been removed since nfs-utils 1.2.0. rpc.gssd
from nfs-utils 1.2.0 complains with:

Mar  8 16:28:20 anubis rpc.gssd[1982]: rpcsec_gss: gss_init_sec_context:
(major) Unspecified GSS failure.  Minor code may provide more information
- (minor) No supported encryption types (config file error?) =


rpc.gssd from 1.2.2 segfaults.

-- =

Luk=E1=B9 Hejtm=E1nek
