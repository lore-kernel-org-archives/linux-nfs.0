Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:46915 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751207Ab2IWNuh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Sep 2012 09:50:37 -0400
Received: by pbbrr4 with SMTP id rr4so5643550pbb.19
        for <linux-nfs@vger.kernel.org>; Sun, 23 Sep 2012 06:50:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120920193349.GA18143@fieldses.org>
References: <CAJ75kXZuM_p3qknD4RgdjLLWd393u02S5FKQyu3Q8y8NwmfiVw@mail.gmail.com>
 <CAJ75kXagDP6TPO+7pCCcUyac+ViPgKVThTsuehHNi_xwTpnGiQ@mail.gmail.com>
 <CAHVgHyXMR=Bf02pWe=McHZPu+iNTZvhs6vHVx1ie404QebF86g@mail.gmail.com>
 <20120920161716.GB4521@fieldses.org> <CAHVgHyXDs7=rafH2_pQ7T0cwzoO-LGgtVB+8E_btt5E0v9YTdg@mail.gmail.com>
 <CAHVgHyUqNWakh6h18wZDGB91GJo-crtpPjmUUB+00HTMvePRNg@mail.gmail.com> <20120920193349.GA18143@fieldses.org>
From: William Dauchy <wdauchy@gmail.com>
Date: Sun, 23 Sep 2012 15:50:16 +0200
Message-ID: <CAJ75kXYbup8Z0Bw3LQxQk+B7P_u+J8zwef-6BQYrYH=TgnB4Ow@mail.gmail.com>
Subject: Re: unhandled error -10026
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Andy Adamson <androsadamson@gmail.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        R.Eggermont@tudelft.nl
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 20, 2012 at 9:33 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> William, is this easy to reproduce?  Would it be possible to get a
> network trace covering the problem?

Unfortunately not. The issue doesn't appear to be reproduced often so
it is difficult for me to debug; but if I find a way to reproduce it,
I will come back with some more information.
I will also dig on server side code and check the cases it could
answer this error.

Thank you for all this information,
-- 
William
