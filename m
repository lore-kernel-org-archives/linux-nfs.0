From: "Jeff Chua" <jeff.chua.linux@gmail.com>
Subject: Re: [2/4] 2.6.23-rc5: known regressions
Date: Mon, 3 Sep 2007 20:36:32 +0800
Message-ID: <b6a2187b0709030536w3e40f12bk4d25b6eb954d22b6@mail.gmail.com>
References: <46DBD982.3080102@googlemail.com> <46DBDD8B.7040706@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"Ingo Molnar" <mingo@elte.hu>, Markus <lists4me@web.de>,
	"Antonino A. Daplas" <adaplas@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>, "Len Brown" <lenb@kernel.org>,
	dth <dth@dth.net>, linux-fsdevel@vger.kernel.org,
	nfs@lists.sourceforge.net,
	"Trond Myklebust" <Trond.Myklebust@netapp.com>,
	"Andrew Clayton" <andrew@digital-domain.net>,
	"Peter Kovar" <peter.kovar@gmail.com>
To: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <46DBDD8B.7040706@googlemail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On 9/3/07, Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Subject         : console is messed up after resume from s2ram or switching to console from X
> References      : http://lkml.org/lkml/2007/8/4/6
> Last known good : ?
> Submitter       : Jeff Chua <jeff.chua.linux@gmail.com>
> Caused-By       : ?
> Handled-By      : H. Peter Anvin <hpa@zytor.com>
>                   Antonino A. Daplas <adaplas@gmail.com>
> Workaround      : "s2ram --force --acpi_sleep 1 --vbe_mode"
> Status          : problem is being debugged

Michal,

Can you please close this case. I'm using the workaround and satisfied with it.

Thanks,
Jeff.
