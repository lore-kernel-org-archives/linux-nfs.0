From: trond.myklebust@fys.uio.no
Subject: Re: NFS lockd and clustered filesystems
Date: Sat, 28 Feb 2004 01:32:07 +0100 (CET)
Sender: linux-fsdevel-owner@vger.kernel.org
Message-ID: <1123.207.214.87.84.1077928327.squirrel@webmail.uio.no>
References: <OF64DBF011.B2C89360-ON08256E43.007A05D6-08256E47.0083756B@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: "Bruce Allan" <bruce.allan@us.ibm.com>
In-Reply-To: <OF64DBF011.B2C89360-ON08256E43.007A05D6-08256E47.0083756B@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>

P=E5 fr , 27/02/2004 klokka 15:55, skreiv Bruce Allan:
> Hi Trond,
>
> I've been asked to look into an issue that has been previously
> discussed both on and off the lkml. The issue is with lockd not
> invoking a filesystem-specific locking function if one is defined,
> such as with out-of-tree cluster filesystems. You may recall the
> discussions you had with Brian Dixon regarding this sometime
> ago [1]; you didn't like Brian's patch because such a filesystem
> call could hang the single-threaded lockd. As I understand it,
> there was further (off-list?) discussion regarding making lockd
> multi-threaded to get around this problem. In light of recent
> announcements/discussions regarding cluster filesystems on
> Linux (eg. RedHat's acquisition of Sistina, Linus' remarks about
> clustered filesystems being one of the main things to work on
> for 2.7), is the time right to re-address this matter? How
> receptive would you be to these previous patches
> (including the multi-threaded lockd patch) being ported to 2.6,
> or would you prefer another method?

I have no philosophical objections to doing this as long as the issue o=
f
lockd potentially hanging is addressed.

Note, though, that Brian's patch can probably be implemented in a more
efficient manner in 2.6.x now that we have generic workqueues in the
kernel. They could be used to offload the work without having to fork a
bunch of threads every time someone wants to use the cluster system.

Cheers,
  Trond

-
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
