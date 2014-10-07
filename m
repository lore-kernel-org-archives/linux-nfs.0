Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:49778 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754619AbaJGRe7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Oct 2014 13:34:59 -0400
MIME-Version: 1.0
In-Reply-To: <20141007171703.GA30274@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-3-git-send-email-jlayton@primarydata.com>
	<CACE9dm-gEfVnHvESfewAPx1vDSdpUW+za=H_zpA8hJd55AR=tA@mail.gmail.com>
	<20141007171703.GA30274@infradead.org>
Date: Tue, 7 Oct 2014 20:34:57 +0300
Message-ID: <CACE9dm_NKwFV__MeQw039yenbjzT+XwakgxZuynr25EVWHjRdQ@mail.gmail.com>
Subject: Re: [PATCH v2 02/17] security: make security_file_set_fowner,
 f_setown and __f_setown void return
From: Dmitry Kasatkin <dmitry.kasatkin@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 October 2014 20:17, Christoph Hellwig <hch@infradead.org> wrote:
> On Tue, Oct 07, 2014 at 08:11:42PM +0300, Dmitry Kasatkin wrote:
>> If file_set_fowner op is now type of "void", how you can actually
>> return the value?
>> I think compiler must give error. How could you compile it?
>
> Returning void values is a GNU extension.  I've seen it in a few
> places in the kernel.  Although in general I'd prefer it we'd remove
> it (and have the compiler warn about it).
>

Cool. There were patches around to use LLVM as well.
Will it work there?

-- 
Thanks,
Dmitry
