From: kaza@kk.iij4u.or.jp
Subject: Re: [PATCH] zerocopy NFS for 2.5.36
Date: Thu, 17 Oct 2002 02:02:15 +0900
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20021016170213.GR19806%kaza@kk.iij4u.or.jp>
References: <15786.23306.84580.323313@notabene.cse.unsw.edu.au> <20021014.210144.74732842.taka@valinux.co.jp> <15788.57476.858253.961941@notabene.cse.unsw.edu.au> <20021016.200900.128068491.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, davem@redhat.com,
	linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20021016.200900.128068491.taka@valinux.co.jp>
List-ID: <nfs.lists.sourceforge.net>

Hello,

On Wed, Oct 16, 2002 at 08:09:00PM +0900,
Hirokazu Takahashi-san wrote:
> > After thinking about this some more, I suspect it would have to be
> > quite large scale SMP to get much contention.
> 
> I have no idea how much contention will happen. I haven't checked the
> performance of it on large scale SMP yet as I don't have such a great
> machines.
> 
> Does anyone help us?

Why don't you propose the performance test to OSDL? (OSDL-J is more
better, I think)   OSDL provide hardware resources and operation staffs.

If you want, I can help you to propose it. :-)

-- 
Ko Kazaana / editor-in-chief of "TechStyle" ( http://techstyle.jp/ )
GnuPG Fingerprint = 1A50 B204 46BD EE22 2E8C  903F F2EB CEA7 4BCF 808F
