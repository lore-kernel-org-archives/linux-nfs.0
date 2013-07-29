Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20219 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752755Ab3G2O4e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jul 2013 10:56:34 -0400
Date: Mon, 29 Jul 2013 16:51:12 +0200
From: Oleg Nesterov <oleg@redhat.com>
To: Andrew Vagin <avagin@parallels.com>
Cc: Toralf =?iso-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
        Andrey Vagin <avagin@openvz.org>, "Serge E. Hallyn" <serge@hallyn.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: fuzz tested user mode linux core dumps in
	fs/lockd/clntproc.c:131
Message-ID: <20130729145112.GA10489@redhat.com>
References: <51F39AE8.3090401@gmx.de> <20130727170051.GA31447@redhat.com> <51F5381D.1080904@gmx.de> <20130728175828.GA15020@redhat.com> <20130729062905.GA28282@paralelels.com> <20130729131031.GA6157@redhat.com> <20130729142749.GA27205@paralelels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130729142749.GA27205@paralelels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/29, Andrew Vagin wrote:
>
> I don't have objections against this patch. All my tests work find.

Great, thanks for confirmation. Can I translate this into your
acked-by or tested-by if I send this patch?

(there is another fix from Eric, it is not clear to me if I
 should send it right now).

Oleg.

