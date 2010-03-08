From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 14:48:36 -0500
Message-ID: <4d569c331003081148y680d939ej97477c6ce9230ef9@mail.gmail.com>
References: <4B9021EF.60309@oracle.com> <4B903485.1030608@oracle.com>
	<20100304224011.GN19154@ics.muni.cz>
	<20100308101607.GR19154@ics.muni.cz>
	<20100308070209.7cabb55f@tlielax.poochiereds.net>
	<20100308121117.GW19154@ics.muni.cz>
	<4d569c331003080544n40a12f52x74b39420a697e546@mail.gmail.com>
	<20100308153042.GB19154@ics.muni.cz>
	<4d569c331003081121p73fac846g1a1ef32f1ec8132@mail.gmail.com>
	<20100308194054.GC19154@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100308194054.GC19154@ics.muni.cz>
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

2010/3/8 Lukas Hejtmanek <xhejtman@ics.muni.cz>:
> On Mon, Mar 08, 2010 at 02:21:57PM -0500, Kevin Coffman wrote:
>> So you probably need to add "allow_weak_crypto =3D true" to your
>> /etc/krb5.conf file. =A0(I believe MIT added an API to allow this
>> programmatically, but I haven't been following closely enough.)
>
> well, this one fixes problem with nfs-utils-1.2.0.
>
> The 1.2.2 still segfaults. Any other thoughts or should I start to play b=
isect
> game?

Interesting.  Are there any extra Debian nfs-utils patches?  I just
tried this with vanilla nfs-utils-1.2.2 and the latest Kerberos (w/o
the allow_weak_crypto config setting) and do not get a segfault.  I
get these error messages:

Mar  8 14:40:18 jazz rpc.gssd[7925]: Full hostname for
'screamer.citi.umich.edu' is 'screamer.citi.umich.edu'
Mar  8 14:40:18 jazz rpc.gssd[7925]: Full hostname for
'jazz.citi.umich.edu' is 'jazz.citi.umich.edu'
Mar  8 14:40:18 jazz rpc.gssd[7925]: Key table entry not found while
getting keytab entry for 'root/jazz.citi.umich.edu@'
Mar  8 14:40:18 jazz rpc.gssd[7925]: Success getting keytab entry for
'nfs/jazz.citi.umich.edu@'
Mar  8 14:40:18 jazz rpc.gssd[7925]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_CITI.UMICH.EDU' are good until 1268437187
Mar  8 14:40:18 jazz rpc.gssd[7925]: INFO: Credentials in CC
'FILE:/tmp/krb5cc_machine_CITI.UMICH.EDU' are good until 1268437187
Mar  8 14:40:18 jazz rpc.gssd[7925]: using
FILE:/tmp/krb5cc_machine_CITI.UMICH.EDU as credentials cache for
machine creds
Mar  8 14:40:18 jazz rpc.gssd[7925]: using environment variable to
select krb5 ccache FILE:/tmp/krb5cc_machine_CITI.UMICH.EDU
Mar  8 14:40:18 jazz rpc.gssd[7925]: creating context using fsuid 0 (save_u=
id 0)
Mar  8 14:40:18 jazz rpc.gssd[7925]: creating tcp client for server
screamer.citi.umich.edu
Mar  8 14:40:18 jazz rpc.gssd[7925]: DEBUG: port already set to 2049
Mar  8 14:40:18 jazz rpc.gssd[7925]: creating context with server
nfs@screamer.citi.umich.edu
Mar  8 14:40:18 jazz rpc.gssd[7925]: WARNING: Failed to create krb5
context for user with uid 0 for server screamer.citi.umich.edu
Mar  8 14:40:18 jazz rpc.gssd[7925]: WARNING: Failed to create machine
krb5 context with credentials cache
FILE:/tmp/krb5cc_machine_CITI.UMICH.EDU for server
screamer.citi.umich.edu
Mar  8 14:40:18 jazz rpc.gssd[7925]: WARNING: Failed to create machine
krb5 context with any credentials cache for server
screamer.citi.umich.edu
Mar  8 14:40:18 jazz rpc.gssd[7925]: doing error downcall
Mar  8 14:40:18 jazz rpc.gssd[7925]: Failed to write error downcall!
Mar  8 14:40:18 jazz rpc.gssd[7925]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnta
Mar  8 14:40:18 jazz rpc.gssd[7925]: destroying client
/var/lib/nfs/rpc_pipefs/nfs/clnt9

Running rpc.gssd with no debugging, I get:

Mar  8 14:47:02 jazz rpc.gssd[8006]: ERROR: No credentials found for
connection to server screamer.citi.umich.edu
