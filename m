Received: from mail-yb1-f177.google.com (mail-yb1-f177.google.com [209.85.219.177])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 01EEC134747
	for <linux-nfs@vger.kernel.org>; Wed, 24 Jan 2024 21:05:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.177
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1706130361; cv=none; b=EDqLldvewjfaPsb9YesaTQoATqU3zrLxTcNkqgnPHH2do88Tc1txB+36V0U3h29CC1u9muRbfwpVNzRFx1Ei+lpoq0b6suqIeNlpavdoo4lFPstHFOP+tR1r/q/osVLfuk52uUwrLlioSjc/R3Mnt06VKiti3D5Ccl2ne/W/emI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1706130361; c=relaxed/simple;
	bh=1XHMNcEFasNUgX7bnllm2eM2CpBRkPZ29du/IIPDEZk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=crMAedFDJu1cDzTudnSUN35dTCc0oEazYtdS3KAUUCnvoVEMMaRZgtlQtqw9pGgdMRbuatb5TWEv/0hJwWmo8BMR3e7OI1i55F9ZkBhA4m09Fu0yXwFEXbQC3qu0Kt+eL52fA42Rn92KwOwaKryT3cSsvqilwTEXueqfOfqLZac=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com; spf=none smtp.mailfrom=toxicpanda.com; dkim=pass (2048-bit key) header.d=toxicpanda-com.20230601.gappssmtp.com header.i=@toxicpanda-com.20230601.gappssmtp.com header.b=HD57dDeA; arc=none smtp.client-ip=209.85.219.177
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=toxicpanda.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=toxicpanda-com.20230601.gappssmtp.com header.i=@toxicpanda-com.20230601.gappssmtp.com header.b="HD57dDeA"
Received: by mail-yb1-f177.google.com with SMTP id 3f1490d57ef6-dae7cc31151so4592195276.3
        for <linux-nfs@vger.kernel.org>; Wed, 24 Jan 2024 13:05:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=toxicpanda-com.20230601.gappssmtp.com; s=20230601; t=1706130358; x=1706735158; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:from:to:cc:subject:date:message-id:reply-to;
        bh=xs6KKsKp0che6Gt2J7h/LsT7AD/t5Dd8FEYDtGKBA8o=;
        b=HD57dDeAS8aro7grewx1wBNmuyp6p0EOxfl1bre9R4jTHHp9V1USmK3knFKU8FVk+f
         SM9Ti57M74oVZDJ1zK934MkyoSdSSyYRryTNu1GIM3SpPL+pCpMw5ZmDZoeD3jG1e4YL
         GcH7at1cwG1DT26rGr9etxuTtgp750RUjiy/DY7dmljm9VMvyVuQNgBDy9UrrIMrxAvd
         4UNN+SSMkU9+Ag+j0w4wTvABEtFyWOqgURvtwVQanGm3gZjnfqFtMHI/aJUt2y4fY1tY
         nXWHzLZYN2erzwASAKTq5QQoJuEFixTbKXHwCVkf9N7E4N8dqlCnTPHnCG8/9KJ9DxAi
         9y2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1706130358; x=1706735158;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:cc:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=xs6KKsKp0che6Gt2J7h/LsT7AD/t5Dd8FEYDtGKBA8o=;
        b=Vao98cOabfZbwsuBc/Os4fCOa7ww5rG5Y0h9f28IgRglUksas1JqoxeQvJvmMPFfCu
         XlRwpUaqUsCcK967VgWearVUIWrlufPSoEqQsLz7WEIhegYP/78pgg6beBGsPn3OqM18
         T+putEIWUr6WKaE4oPD3qdNli02H2v2AmudlVl4FK37nSgd5GZsDP+34mTu5qGuh/JJf
         xRUE98e7AELI+BjFlZ9cihO2n0wYCrYG5y7+nl/7DPkn/IHTm6gnqkbEncETmxknRZH1
         0r/BU/jiVFPr+eDVuj0ATEyjnfXV6p1rzufPqzlVXOCi31WVI0kXq7k8tvzKPeMfOhS9
         0Arw==
X-Gm-Message-State: AOJu0Yx9KTPKQSSfg015NkIUIivQZ1E79Re6QgZfssjhHLxNWGee6sZP
	FKW4dvKVPAY6iRZhjol/QRgBQ19EPdJzqt4ta7L9p8KnpfE7ESQ8uxoqOmAy488=
X-Google-Smtp-Source: AGHT+IFG3MtH7NGpSUJ3amoepjRPnOjTXNYHmPZQZuf1VtKvEYvqXQnUHCjkRSMw7RI/tzm+fG/Efw==
X-Received: by 2002:a25:a025:0:b0:dc2:3fbd:8300 with SMTP id x34-20020a25a025000000b00dc23fbd8300mr1315470ybh.10.1706130357941;
        Wed, 24 Jan 2024 13:05:57 -0800 (PST)
Received: from localhost (076-182-020-124.res.spectrum.com. [76.182.20.124])
        by smtp.gmail.com with ESMTPSA id u11-20020a25840b000000b00dc218e084fbsm2952173ybk.28.2024.01.24.13.05.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 24 Jan 2024 13:05:57 -0800 (PST)
Date: Wed, 24 Jan 2024 16:05:56 -0500
From: Josef Bacik <josef@toxicpanda.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org, kernel-team@fb.com
Subject: Re: [PATCH 2/2] nfsd: expose /proc/net/sunrpc/nfsd in net namespaces
Message-ID: <20240124210556.GA1237643@perftesting>
References: <cover.1706124811.git.josef@toxicpanda.com>
 <71058c29683d44644aba8ab295fa028ee41365a8.1706124811.git.josef@toxicpanda.com>
 <ZbFzxmV6zgi/TACb@tissot.1015granger.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ZbFzxmV6zgi/TACb@tissot.1015granger.net>

On Wed, Jan 24, 2024 at 03:32:06PM -0500, Chuck Lever wrote:
> On Wed, Jan 24, 2024 at 02:37:00PM -0500, Josef Bacik wrote:
> > We are running nfsd servers inside of containers with their own network
> > namespace, and we want to monitor these services using the stats found
> > in /proc.  However these are not exposed in the proc inside of the
> > container, so we have to bind mount the host /proc into our containers
> > to get at this information.
> > 
> > Separate out the stat counters init and the proc registration, and move
> > the proc registration into the pernet operations entry and exit points
> > so that these stats can be exposed inside of network namespaces.
> 
> Maybe I missed something, but this looks like it exposes the global
> stat counters to all net namespaces...? Is that an information leak?
> As an administrator I might be surprised by that behavior.
> 
> Seems like this patch needs to make nfsdstats and nfsd_svcstats into
> per-namespace objects as well.
> 

Yeah I was worried you might say that.  I misread the sunrpc code and thought it
was handling the magic for me, but it's literally just making the proc entry
under its own thing.  I'll brb with proper patches.  Thanks,

Josef
