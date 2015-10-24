Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail1.vodafone.ie ([213.233.128.43]:58563 "EHLO
	mail1.vodafone.ie" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751844AbbJXMCZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Oct 2015 08:02:25 -0400
Subject: Re: [PATCH v7 5/4] copy_file_range.2: New page documenting
 copy_file_range()
To: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-api@vger.kernel.org, zab@zabbo.net, viro@zeniv.linux.org.uk,
        clm@fb.com, darrick.wong@oracle.com, mtk.manpages@gmail.com,
        andros@netapp.com, hch@infradead.org
References: <1445628736-13058-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
From: =?UTF-8?Q?P=c3=a1draig_Brady?= <P@draigBrady.com>
Message-ID: <562B734D.50800@draigBrady.com>
Date: Sat, 24 Oct 2015 13:02:21 +0100
MIME-Version: 1.0
In-Reply-To: <1445628736-13058-6-git-send-email-Anna.Schumaker@Netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23/10/15 20:32, Anna Schumaker wrote:
> +    len = stat.st_size;
> +
> +    fd_out = open(argv[2], O_CREAT|O_WRONLY|O_TRUNC, 0644);
> +    if (fd_out == \-1) {
> +        perror("open (argv[2])");
> +        exit(EXIT_FAILURE);
> +    }
> +
> +    do {
> +        ret = copy_file_range(fd_in, NULL, fd_out, NULL, len, 0);
> +        if (ret == \-1) {
> +            perror("copy_file_range");
> +            exit(EXIT_FAILURE);
> +        }
> +
> +        len \-= ret;
> +    } while (len > 0);

Is this an infinite loop if len decreases before the copy completes?
Perhaps this should be: while (len && ret);

Otherwise this set looks good.

I'm a bit worried about the sparse expansion and default reflinking
which might preclude cp(1) from using this call in most cases, but I will
test and try to use it. coreutils has heuristics for determining if files
are remote, which we might use to restrict to that use case.

thanks,
Pádraig.
