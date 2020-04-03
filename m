Return-Path: <SRS0=7+b/=5T=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EA4B2C43331
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Apr 2020 15:15:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B275420719
	for <linux-nfs@archiver.kernel.org>; Fri,  3 Apr 2020 15:15:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585926939;
	bh=RnQjE0a9EtpoS4LuXSasTHxLO5ZnjWgSgaf/Z5n3B34=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:List-ID:From;
	b=oMyo7HcAkdYlNn86+p5/0kadyh6kViF/pOfE/XBeKiqUfXT2BbDjOchKl42SVrklz
	 Rm2kTk3157mj381QKrP/6vEIE/IX5WsGjwMi+p7WPsk9zRGo8J998WbBJrr7jhuMNu
	 H0Y1Yvxp9q+7e7OB4dRiTbgqWlZWJB12bpeWJRk4=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2403795AbgDCPPj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 3 Apr 2020 11:15:39 -0400
Received: from mail-wm1-f67.google.com ([209.85.128.67]:40000 "EHLO
        mail-wm1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728203AbgDCPPj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2020 11:15:39 -0400
Received: by mail-wm1-f67.google.com with SMTP id a81so8089510wmf.5;
        Fri, 03 Apr 2020 08:15:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to;
        bh=dYdrlxthVlPe+P4Bo/WAF0UgbtJBHrL0k9DfDVII2Po=;
        b=i5V/i5DN0+JEC32sOErElWNBGY6eza703tmknsLlgYO7+FUzTYTqdMExl9mMc8xy/P
         8YeZfkWs091iG+mSgbyVEyQ5RSqqmFYEG5CsG+QB9LTVAMoSV+GMH0OjL0ETZzBVse25
         UNSCC6aQmYHhOK1HXg8JMXKDHESWWz/rzKfArNjyuZi855EW7AiB9BC3fcXrlPSslWPD
         aOww9F89L93+qb7pq5kNl/Jb+Jk0vyM07Bb+GL+DXOtgUX5QUJgdlYLSDV4uTf1xHgNW
         JunooyFsDT28mr+1ipQfRH3J48NwU1Aa+GewuLjFrnve5zFMQZOwzNXD9jQ9cwGxXavu
         IE4A==
X-Gm-Message-State: AGi0PuYD/qfTK1nKs+6qMEQGnnIE6QfS/qoA0qzlufgmt+2uWmJ4sXzF
        Ab4yiEyflHlCYuCFihchYKQ=
X-Google-Smtp-Source: APiQypKaA3KcZEPlcMUrZKNSftTVMLDba3dS2MeXCo8avgaqUoIp3BTJpvRNOS+1foU8DFf0+2/hgg==
X-Received: by 2002:a05:600c:2188:: with SMTP id e8mr9206977wme.121.1585926936992;
        Fri, 03 Apr 2020 08:15:36 -0700 (PDT)
Received: from localhost (ip-37-188-180-223.eurotel.cz. [37.188.180.223])
        by smtp.gmail.com with ESMTPSA id w4sm11668874wmc.18.2020.04.03.08.15.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 03 Apr 2020 08:15:36 -0700 (PDT)
Date:   Fri, 3 Apr 2020 17:15:34 +0200
From:   Michal Hocko <mhocko@kernel.org>
To:     NeilBrown <neilb@suse.de>
Cc:     Trond Myklebust <trondmy@hammerspace.com>,
        "Anna.Schumaker@Netapp.com" <Anna.Schumaker@Netapp.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Jan Kara <jack@suse.cz>, linux-mm@kvack.org,
        linux-nfs@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 1/2] MM: replace PF_LESS_THROTTLE with PF_LOCAL_THROTTLE
Message-ID: <20200403151534.GG22681@dhcp22.suse.cz>
References: <87tv2b7q72.fsf@notabene.neil.brown.name>
 <87v9miydai.fsf@notabene.neil.brown.name>
 <87sghmyd8v.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87sghmyd8v.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu 02-04-20 10:53:20, Neil Brown wrote:
> 
> PF_LESS_THROTTLE exists for loop-back nfsd, and a similar need in the
> loop block driver, where a daemon needs to write to one bdi in
> order to free up writes queued to another bdi.
> 
> The daemon sets PF_LESS_THROTTLE and gets a larger allowance of dirty
> pages, so that it can still dirty pages after other processses have been
> throttled.
> 
> This approach was designed when all threads were blocked equally,
> independently on which device they were writing to, or how fast it was.
> Since that time the writeback algorithm has changed substantially with
> different threads getting different allowances based on non-trivial
> heuristics.  This means the simple "add 25%" heuristic is no longer
> reliable.
> 
> This patch changes the heuristic to ignore the global limits and
> consider only the limit relevant to the bdi being written to.  This
> approach is already available for BDI_CAP_STRICTLIMIT users (fuse) and
> should not introduce surprises.  This has the desired result of
> protecting the task from the consequences of large amounts of dirty data
> queued for other devices.

While I understand that you want to have per bdi throttling for those
"special" files I am still missing how this is going to provide the
additional room that the additnal 25% gave them previously. I might
misremember or things have changed (what you mention as non-trivial
heuristics) but PF_LESS_THROTTLE really needed that room to guarantee a
forward progress. Care to expan some more on how this is handled now?
Maybe we do not need it anymore but calling that out explicitly would be
really helpful.
-- 
Michal Hocko
SUSE Labs
