Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57624 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750936AbeC0Tch (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 27 Mar 2018 15:32:37 -0400
Date: Tue, 27 Mar 2018 15:32:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Patrick Goetz <pgoetz@math.utexas.edu>
Cc: "Jianhong.Yin" <yin-jianhong@163.com>, bfields@redhat.com,
        linux-nfs@vger.kernel.org, Jianhong Yin <jiyin@redhat.com>
Subject: Re: [PATCH 1/2] [pynfs] remove redundant ply, gssapi and rpcgen.py
 modules
Message-ID: <20180327193236.GB22077@fieldses.org>
References: <20180327172709.13071-1-yin-jianhong@163.com>
 <20180327183725.GA22077@fieldses.org>
 <fc72ad79-c558-f6bb-fa96-870ba522a427@math.utexas.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <fc72ad79-c558-f6bb-fa96-870ba522a427@math.utexas.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Mar 27, 2018 at 02:24:00PM -0500, Patrick Goetz wrote:
> On 03/27/2018 01:37 PM, J. Bruce Fields wrote:
> >I've never used pip.  Googling around, I see some people warn about
> >potential conflicts between pip and rpm/dpkg.  Would it be better to
> >recommend pip install --user?
> 
> Pip is just the python package installer, similar to
> install.packages() in R or cpan in perl.
> 
> The issue with rpm/dpkg/pacman is that the distribution package
> manager won't know about anything that you've installed using pip,
> which could mean, for example, that you've met a library dependency
> using pip, but apt or yum insist that the library is missing and
> needs to be installed.

Any reason not to change the README to recommend

	pip install --user ply gssapi

? Seems like the safer default.

Actually now that I look my Fedora 27 laptop has both python-gssapi and
python-ply packages, so maybe there's no need for pip.

--b.
