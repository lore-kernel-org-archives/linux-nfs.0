Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:33039 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758241Ab1JFMaH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 08:30:07 -0400
Message-ID: <4E8D9F3F.4090004@parallels.com>
Date: Thu, 06 Oct 2011 16:29:51 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
To: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Kirill A. Shutemov" <kas@openvz.org>,
        "jlayton@redhat.com" <jlayton@redhat.com>
Subject: Re: network-namespace-aware nfsd
References: <20111005150214.GA18449@fieldses.org> <4E8C9363.9030303@parallels.com> <20111005181959.GB18449@fieldses.org> <4E8D7BED.6020705@parallels.com>
In-Reply-To: <4E8D7BED.6020705@parallels.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>> Also, do you think per-namespace version support is important?
>>
> 
> Actually, yes, I do.
> As I see it, nfsd filesystem have to virtualized to provide flexible control for 
> server features. If so, then we need to virtualize program as well.

ACK - per namespace version control is required as well.

AFAIK it's performed via sysctl-s and this part (sysctls engine I mean) is already
namespaces aware, thus it will not be the hard part of the implementation :)
