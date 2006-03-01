From: Gopal Santhanam <gopal@nerur.com>
Subject: Re: [NFS] NFSv3 + Kerberos + x86_64 (Fedora Core 4)
Date: Wed, 1 Mar 2006 08:57:51 -0800
Message-ID: <200603010857.51206.gopal@nerur.com>
References: <200603010757.18563.gopal@nerur.com> <4405D159.3070008@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <4405D159.3070008@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

That did the trick!

Thanks for the help and the ultra-speedy reply!

Gopal


On Wednesday 01 March 2006 08:52, Steve Dickson wrote:
> Gopal Santhanam wrote:
> > Hi all,
> >
> > I have been using FC4's kernel-2.6.15-1.1831 on both
> > i686 and x86_64 architecture machines.
> >
> > I want to use NFSv3 with Kerberos.  This works fine
> > on i686 with the aforementioned FC4 kernel.  I am
> > able to do the following:
> >
> > 1) Setup NFS server with kerberos
> >
> > 2) Mount on NFS client with -o sec=krb5.
> >
> >
> > Now, if I have (1) on i686 and do (2) on x86_64, things just
> > break:
> >
> > {root@x86_64client:3:~} mount -o sec=krb5
> > server:/export/test /mnt
> > {root@x86_64client:4:~} ls -al /mnt
> > ls: /mnt: Broken pipe
> >
> >
> >
> > The clients are setup exactly the same
> > (both have /etc/krb5.keytab, /etc/idmapd.conf).
> > They are both running rpc.idmapd and rpc.gssd.
> >
> > An important thing to mention is that rpc.gssd is still
> > running after the mount command but then has vanished
> > (crashed?) after the ls.
>
> Try changing the library in /etc/gssapi_mech.conf from
> /usr/lib/libgssapi_krb5.so to simply libgssapi_krb5.so.2
>
> steved.
