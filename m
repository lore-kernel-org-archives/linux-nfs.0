From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Thu, 4 Mar 2010 23:40:11 +0100
Message-ID: <20100304224011.GN19154@ics.muni.cz>
References: <4B7D4E55.4040002@RedHat.com> <20100304201941.GL19154@ics.muni.cz>
	<4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	<4B903485.1030608@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org,
	Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4B903485.1030608@oracle.com>
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

On Thu, Mar 04, 2010 at 05:30:29PM -0500, Chuck Lever wrote:
> I use
> =

>  $ make distclean
>  $ sh ./autogen.sh
> =

> then run ./configure

I did this but rpc/auth_gss.h still cannot be found:
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wstrict-prototypes  -pipe -g -O2    -g -O2 -MT gssd-context.o -MD -MP -MF
.deps/gssd-context.Tpo -c -o gssd-context.o `test -f 'context.c' || echo
'./'`context.c
context.c:40:26: error: rpc/auth_gss.h: No such file or directory

but this one works:
gcc -DHAVE_CONFIG_H -I. -I../../support/include   -D_GNU_SOURCE -Wall
-Wstrict-prototypes  -pipe -g -O2    -g -O2 -MT gssd-context.o -MD -MP -MF
.deps/gssd-context.Tpo -c -o gssd-context.o `test -f 'context.c' || echo
'./'`context.c `pkg-config --cflags librpcsecgss`

-- =

Luk=E1=B9 Hejtm=E1nek
