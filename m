From: "Chuck Lever" <chuck.lever@oracle.com>
Subject: Re: Confused about 'sloppy' option parsing in NFS.
Date: Fri, 5 Sep 2008 12:27:17 -0400
Message-ID: <76bd70e30809050927k2a080ffdq47cade676afa1b13@mail.gmail.com>
References: <18624.55656.904241.183933@notabene.brown>
Reply-To: chucklever@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Trond Myklebust" <Trond.Myklebust@netapp.com>,
	linux-nfs@vger.kernel.org
To: "Neil Brown" <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.184]:53563 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753864AbYIEQ1U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2008 12:27:20 -0400
Received: by gv-out-0910.google.com with SMTP id e6so42751gvc.37
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2008 09:27:18 -0700 (PDT)
In-Reply-To: <18624.55656.904241.183933-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 5, 2008 at 3:02 AM, Neil Brown <neilb@suse.de> wrote:
>
> The kernel used by OpenSUSE-11.0 complains when automount passes a
> 'grpid' option.  So I'm looking at backporting the 'sloppy' option
> parsing fix.  But I'm confused.
>
> Looking at commit f45663ce5fb30f76a3414ab3ac69f4dd320e760a
>
> It introduced 'sloppy' and 'errors' in nfs_parse_mount_options,
> possibly sets them to some non-zero value based on what it finds, and
> then does absolutely nothing with them.
>
> nfs_parse_mount_options only returns zero if:
>  - memalloc fails
>  - security_sb_parse_opts_str fails
>
> But never if there is an unrecognised argument.
>
> This functionality is obviously quite trivial to backport, but I
> wonder if it is correct.
>
> Is it just a simple slip up, or am I missing something?

There was a lot of controversy around this patch and several others in
the same area.  As usual an important hunk got dropped in the final
version I sent in.  Something like this:

@@ -1182,6 +1250,12 @@ static int nfs_parse_mount_options(char *raw,
                break;
        }

+       if (errors > 0) {
+               dfprintk(MOUNT, "NFS: parsing encountered %d error%s\n",
+                               errors, (errors == 1 ? "" : "s"));
+               if (!sloppy)
+                       return 0;
+       }
        return 1;

 out_nomem:

I found this in my git repo on linux-nfs.org in commit
17cdb8c69388cc7611adb4d43c46cfa1ec4938c2.  I can post a tested delta
for 26-stable and 27-rc later today.

--
Chuck Lever
