From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] 1/2 SELinux: Add get, set, and cloning of superblock security information
Date: Thu, 6 Sep 2007 08:59:03 -0700 (PDT)
Message-ID: <636439.78887.qm@web36607.mail.mud.yahoo.com>
References: <1189030563.3460.41.camel@dhcp231-215.rdu.redhat.com>
Reply-To: casey@schaufler-ca.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: sds@tycho.nsa.gov, jmorris@namei.org, steved@redhat.com,
        trond.myklebust@fys.uio.no
To: Eric Paris <eparis@redhat.com>, selinux@tycho.nsa.gov,
        nfs@lists.sourceforge.net
Return-path: <owner-selinux-MESi4pFTnrejpDF0oNHs+n7yKkN/O5/Z@public.gmane.org>
In-Reply-To: <1189030563.3460.41.camel-8EcGF3LoIEk5T7vyJU6V4x/sF2h8X+2i0E9HWUfgJXw@public.gmane.org>
Sender: owner-selinux@tycho.nsa.gov
List-ID: <nfs.lists.sourceforge.net>


--- Eric Paris <eparis@redhat.com> wrote:

> Adds security_get_sb_mnt_opts, security_set_sb_mnt_opts, and
> security_clont_sb_mnt_opts to the LSM and to SELinux.  This is in
> preparation for NFS to be able to own its own mount options and remove
> the NFS specific code from SELinux.

What is the purpose of security_clone_sb_mnt_opts? I see where it is
being used, but it's not clear to me why it is necessary. The old SELinux
code doesn't clone the options, it filters out the ones it cares about.
If that is the behavior you'd expect of this hook, I suggest the name
reflect that, perhaps security_filter_sb_mnt_opts.


Casey Schaufler
casey@schaufler-ca.com
