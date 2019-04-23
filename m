Return-Path: <SRS0=AvAq=SZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A97E8C10F11
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 02:22:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5A1D72077C
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Apr 2019 02:22:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=nazar.ca header.i=@nazar.ca header.b="azd3krL5"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730120AbfDWCWk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 22:22:40 -0400
Received: from ny019.relay.arandomserver.com ([172.96.188.181]:44371 "EHLO
        ny019.relay.arandomserver.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1730114AbfDWCWk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Apr 2019 22:22:40 -0400
Received: from nyc006.hawkhost.com ([172.96.186.142])
        by se004.arandomserver.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
        (Exim 4.89)
        (envelope-from <nazard@nazar.ca>)
        id 1hIl4v-0000Bb-1P; Mon, 22 Apr 2019 21:22:38 -0500
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=nazar.ca;
         s=default; h=Content-Transfer-Encoding:Content-Type:In-Reply-To:MIME-Version
        :Date:Message-ID:From:References:To:Subject:Sender:Reply-To:Cc:Content-ID:
        Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
        :Resent-Message-ID:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
        List-Post:List-Owner:List-Archive;
        bh=d0UIv+qHhsQK18tckJzXu1YoG8vxHYhh9LkHDNRwEdo=; b=azd3krL50sL7u/C/OW9QKJtOrG
        eQngcpekTojifFZ/DNMVg5V8I9wU3cuxJfsX+P0EQZLl9be0KAsdPcFF1yJL7YyxOHZ5JUzdAY/wJ
        GKqcsLm9M7QZFG0QxsxIVS0ZcIZd4F/i8Wd/52ufBgA5W2z09EN88R4M+OYw3Gtr4QvUdpuhkR5RO
        jObOXYTLTVszSPlS4gSXMrgPZQNwJq1SG3FN2bMF9HwakjvPRLQgEVsvh8kT+LwyN2hy8xWh3lUg7
        aKWW9se0mp752oehI5+oE1Ykh2sIy3VDBahUXagaA9RdCm7zTJZTQue+XwLawNiGqqig7z+YvvsXn
        T40f5vvA==;
Received: from [24.114.57.115] (port=55205 helo=[192.168.21.100])
        by nyc006.hawkhost.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES128-GCM-SHA256:128)
        (Exim 4.91)
        (envelope-from <nazard@nazar.ca>)
        id 1hIl4s-0002B7-LC; Mon, 22 Apr 2019 22:22:34 -0400
Subject: Re: nfsd bug after f875a792abe9 (nfsd: allow nfsv3 readdir request to
 be larger.)
To:     NeilBrown <neilb@suse.com>, "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs@vger.kernel.org
References: <5b98d3d5-4b80-8783-b212-4fd7ab9b1006@nazar.ca>
 <87tvep6066.fsf@notabene.neil.brown.name>
From:   Doug Nazar <nazard@nazar.ca>
Message-ID: <03737dac-3d8f-40ce-6760-b04ce2ba5359@nazar.ca>
Date:   Mon, 22 Apr 2019 22:22:33 -0400
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:66.0) Gecko/20100101
 Thunderbird/66.0
MIME-Version: 1.0
In-Reply-To: <87tvep6066.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-AuthUser: nazard@nazar.ca
X-Originating-IP: 172.96.186.142
X-SpamExperts-Domain: nyc006.hawkhost.com
X-SpamExperts-Username: relay
Authentication-Results: arandomserver.com; auth=pass (login) smtp.auth=relay@nyc006.hawkhost.com
X-SpamExperts-Outgoing-Class: unsure
X-SpamExperts-Outgoing-Evidence: Combined (0.31)
X-Recommended-Action: accept
X-Filter-ID: EX5BVjFpneJeBchSMxfU5oWWzVZWVY8eczJqW/Gvl9t602E9L7XzfQH6nu9C/Fh9KJzpNe6xgvOx
 q3u0UDjvO2qWYvHr5e5v4y+vmIfNl9RTYi2bf0F0JzgUQ/o6tR7CRUw4v+0fRrD6BwODIzG45g3f
 lW5F0IcsXeNa+co8V9yuz0/t36AmZ31zVm+t5xJiQODNnygDL9Z51sdqzGEa0QTJsjWw5+0eZIpQ
 IcK9yrT73sIvjVcN7PAGgTt3i/caamXJnfNsEivVywpSKcw8S9VWAGyvoRQuFtgkm3FOixMqIJr2
 jiE0rcZ9b17snudrbBn8Qh5QRSaSMswP6dh2c+nE6wHyAbSyVXutrqMjgFLISW+2Tk098MVmTeNM
 YJ3dfmni19Fef0ZfHQ8YpvxDNMyfijGS4fJC9e5rYVrBp11lj72SMVZlCwVuLJBzhrT648Wo1jF3
 aTe4Of+op3VeamdmSagpoJ1277s2VUPGFKY73/aCWjINBnUTLlzmPz4RVoMZk3qQvq5jLX10jelH
 HGF7IlRecH31shf2HXUStr5bxdQRLnN5+YAO0i5rdSvp4SLPTReSIWqroBJQpfSDYlaBZax/OZ0Q
 HGT/Dj7PZdZgbBlPTXkrGnKnMp2blIGxOxpyRkl7SiiYJLJ9Krj63cAkUh96XU2CxmvdeaHhndN4
 TjPhCtDZIql2oRaGmhsgNnbvaIOqSCqowW/K1/trVBEVniihuDwEGDcmr6e3OPSA3oGU4LmO8TFC
 xOtMgz6cK2WnsKCFqwajRyUKjKntjONSNvuJlzQl6DUtp/IeZUUzy2WXb5+MzFuthQhFSIA1mTBb
 ylVOuRCWJ+s0iKNJlqCYZPlFsHkha3x9npy1VgW/ON3T8omjTopJj826j7pli78lwmbSZ4PLJVcq
 mEEQVbCs+E+O6if23EybIOdRy/M10OiE3eGccnxTrH5tU/TL6I8K0H/nJ2YtS4nK99ku4EDTGgi3
 Kl7hDlOFwi+9m12whzYfI2D+JMcH7C+fEjd1TAc5RKzuN7NvoMXzx1YtijEvuGslKTrRIXcXpFg5
 ivY=
X-Report-Abuse-To: spam@se001.arandomserver.com
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 2019-04-22 20:21, NeilBrown wrote:
> I think this bug has been fixed, but the fix hasn't landed upstream yet.
> If you
>     git pull git://git.linux-nfs.org/~bfields/linux.git nfs-next

s/nfs-next/nfsd-next/    ;-)

Seems to work fine. I didn't test just that particular patch however, 
just the tree.

I did poke around a bit in the git web interface before, but didn't see 
anything that jumped out at me.

Thanks,
Doug

