From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: ANNOUNCE: nfs-utils-1.2.2 released.
Date: Mon, 8 Mar 2010 13:11:17 +0100
Message-ID: <20100308121117.GW19154@ics.muni.cz>
References: <4B7D4E55.4040002@RedHat.com> <20100304201941.GL19154@ics.muni.cz>
	<4B9021EF.60309@oracle.com> <20100304212149.GM19154@ics.muni.cz>
	<4B903485.1030608@oracle.com> <20100304224011.GN19154@ics.muni.cz>
	<20100308101607.GR19154@ics.muni.cz>
	<20100308070209.7cabb55f@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-2"
Cc: NFSv3 list <linux-nfs@vger.kernel.org>, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20100308070209.7cabb55f@tlielax.poochiereds.net>
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

On Mon, Mar 08, 2010 at 07:02:09AM -0500, Jeff Layton wrote:
> (cc'ing Olga)
> =

> Hmm....gssd in 1.2.2 seems to work fine for me. The only changes in
> that area of the code were some of Olga's patches that went into 1.2.2.
> Olga, any thoughts?

It does not work for me and for one student that works on some patches.

We both have an issue with compilation as well as I mentioned earlier.

> Lukas, could you also tell us what kernel you're using, and maybe send
> the output of ldd against the binary?

My kernel is 2.6.33. The student's kernel is about 2.6.31 or 2.6.32.

ldd /tmp/nfs-utils-1.2.2/utils/gssd/gssd
        linux-vdso.so.1 =3D>  (0x00007fff317ed000)
        libgssapi_krb5.so.2 =3D> /usr/lib/libgssapi_krb5.so.2 (0x00007faa7c=
631000)
        libkrb5.so.3 =3D> /usr/lib/libkrb5.so.3 (0x00007faa7c36d000)
        libk5crypto.so.3 =3D> /usr/lib/libk5crypto.so.3 (0x00007faa7c146000)
        libcom_err.so.2 =3D> /lib/libcom_err.so.2 (0x00007faa7bf42000)
        librpcsecgss.so.3 =3D> /usr/lib/librpcsecgss.so.3 (0x00007faa7bd320=
00)
        libgssglue.so.1 =3D> /usr/lib/libgssglue.so.1 (0x00007faa7bb27000)
        libdl.so.2 =3D> /lib/libdl.so.2 (0x00007faa7b923000)
        libc.so.6 =3D> /lib/libc.so.6 (0x00007faa7b5a2000)
        libkrb5support.so.0 =3D> /usr/lib/libkrb5support.so.0 (0x00007faa7b=
399000)
        libkeyutils.so.1 =3D> /lib/libkeyutils.so.1 (0x00007faa7b196000)
        libresolv.so.2 =3D> /lib/libresolv.so.2 (0x00007faa7af7d000)
        libpthread.so.0 =3D> /lib/libpthread.so.0 (0x00007faa7ad5f000)
        /lib64/ld-linux-x86-64.so.2 (0x00007faa7c886000)

The student uses Debian, I use Ubuntu (so similar distros).

Package                      version
----------------------------------------------
libgssapi-krb5-2             1.8+dfsg~alpha1-7
libkrb5-3                    1.8+dfsg~alpha1-7
libk5crypto3                 1.8+dfsg~alpha1-7
libcomerr2                   1.41.10-1ubuntu2
librpcsecgss3                0.19-2
libgssglue1                  0.1-4
libc6                        2.11.1-0ubuntu4
libkrb5support0              1.8+dfsg~alpha1-7
libkeyutils1                 1.2-12

-- =

Luk=E1=B9 Hejtm=E1nek
