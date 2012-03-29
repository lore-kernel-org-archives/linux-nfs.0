Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ee0-f46.google.com ([74.125.83.46]:36991 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751506Ab2C2E7j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Mar 2012 00:59:39 -0400
MIME-Version: 1.0
In-Reply-To: <3379B519-55A9-41F5-AFDA-EBB5BFF891B7@netapp.com>
References: <1332986348.19172.43.camel@lade.trondhjem.org> <CA+55aFwVzhgsw005P3+BkLw_=noJwkQB3G=Q4GqhfLL1WyPHfg@mail.gmail.com>
 <1332986928.19172.45.camel@lade.trondhjem.org> <CA+55aFyQ0r5mN9=3DUVENCtdj8VMLRjiXTc5Xd4o+F=s9B8xMg@mail.gmail.com>
 <1332988097.19172.51.camel@lade.trondhjem.org> <4F73D44C.5090604@panasas.com>
 <CA+55aFyHmQBXw3ik3qv81_3Zp+4r-VUt_TNBs-M19b6Zt7PDeQ@mail.gmail.com>
 <1332994124.30608.5.camel@lade.trondhjem.org> <CA+55aFwxkWpH1WyBnE1Lg9eRAfPsfcyoZev7-O9TGrPKTB1pOg@mail.gmail.com>
 <3379B519-55A9-41F5-AFDA-EBB5BFF891B7@netapp.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 28 Mar 2012 21:59:18 -0700
Message-ID: <CA+55aFxZUv0hVZq=ds3bkMdVgjmpW=3r4Zi+O83Md2n3GKui3g@mail.gmail.com>
Subject: Re: [GIT PULL] Please pull NFS client bugfixes for Linux 3.4...
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 28, 2012 at 9:38 PM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
> When I do the tags/nfs-for-3.4-1, it still gives me that ..BRANCH.NOT.VERIFIED.. crap in the pull message.

Hmm. Maybe it does end up only working for a branch in the pre-1.7.9
days. I haven't tested - I don't use old git versions.

> Furthermore, it fails to actually push the tag to my upstream repository, meaning that I'm still prone to the 'Linus tried to pull, and the commit wasn't there" syndrome.

Well, that's a separate issue. Yes, you obviously need to push first.

I would not object to you scripting the "push before pull request". I
just object to people using a script that is *worse* than what git
actually contains natively to actually generate the pull request.

> Could we perhaps set up a best practices webpage/wiki for this sort of thing with a pointer to that webpage in Documentations/SubmittingPatches? That way maintainers would have a source of information for which versions of 'git' that they need to use in order to provide you with the information that you want.

The nice signed tag understanding came in 1.7.9. But I actually
seriously suggest that all kernel developers use something even more
recent than that, since what changes in 1.7.10 (not released yet, but
the git 'master' branch is at rc3 now) is the extremely nice "make
people actually explain their merges" change.

There have been kernel developers that apparently never even noticed
that they were creating extraneous merges, so I really encourage
everybody to upgrade to current pre-1.7.10 git just so that you are
asked to write a nice merge message when you create a merge. That's
totally independent of the signed tag issue and the nice pull-request
format, though.

And it really is *trivial* to use a modern git instead of whatever
distro version you have. It's literally:

   git clone git://github.com/gitster/git
   cd git
   make
   make install

all as a *regular*user* (do not 'sudo make install'!). That installs
git in your own ~/bin directory, there's no fighting with whatever
distro git versions. No need to uninstall things or worry about
/usr/local or anything like that.

The git master branch is extremely stable, it's not very scary at all
to be up-to-date. And it's almost always better than whatever distro
version you have, and as seen above it really isn't hard to do. You
may need to install a few libraries, but git doesn't really even have
very complex dependencies. The two that might bite some people is the
need for the curl-devel and expat-devel packages.

(If you don't have any development environment at *all*, you need to
install gcc, make, zlib-devel, openssl-devel, and gettext, but those
tend to be in the development base, so you almost certainly already
have them)

Obviously you then need to have something like

    PATH="$(HOME)/bin:$PATH"

in your .bashrc to make sure that your own private binaries override
the system ones, but hey, that's just a good idea regardless if you
are a developer and ever want to use your own programs.

                      Linus
