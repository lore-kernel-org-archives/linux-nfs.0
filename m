Received: from mail-ej1-f42.google.com (mail-ej1-f42.google.com [209.85.218.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 756CB2868AB
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 07:59:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.42
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791532786; cv=pass; b=FDfkotJP0BTutBbDPPgXuo6XC97H+CmQTEeFqSLl1RHhOxzkxgCYe2kpKM9lhnURmKGQFcRjiV94fRYIYnrZ+ciQLjfkwC/u/NnlvqUsc0wtz8sn/0Z+ab2BZOlS1zbCv3w5PEelTVtoXdp7IuQDQBeQ/Cw8eQjX83B2SVRS0bg=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791532786; c=relaxed/simple;
	bh=G1keWcrF72HXepM3vRoDw7uPV90KElzf7SZzId0NiiQ=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Content-Type; b=GTl7p5W1HipWPWejT3JgoGD+iVD47NKJ7cTryVNIuFTXcFYX6mOlWs+aGMBbmN/k9nsxrfw5z+MnDaRtFNDBas2TXtbG6JyuT80IqhxZbDVgxlx2Gtvu2HrKS4aHWpSnR+GaxQxDOTKE9vR0ntOc0YmVPG4bdyNe8sqBKWJ+uu4=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=hW7KYZ4K; arc=pass smtp.client-ip=209.85.218.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hW7KYZ4K"
Received: by mail-ej1-f42.google.com with SMTP id a640c23a62f3a-c2e4df2e26fso510202066b.2
        for <linux-nfs@vger.kernel.org>; Fri, 09 Oct 2026 00:59:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1791532775; cv=none;
        d=google.com; s=arc-20260327;
        b=KWQFoTcLsF64Qa0qnG5sWrzMKKNSN1QYvBNpZkl1eAOsuQdYsVpQEohS8tvLw8Qyec
         ocGmu5t/ieRWlWKPI4xBqE9D+cvna6XmYBpBWKfjovMsbfvYvU6mOUFdhQEUl6sC8XSz
         yLTpjPpJzU+MDmd1aKviOGv0CLW7mRlM+26TP5k9eFDz4gK4BF2HmmF0u4p13HtvDxbc
         WIItrAvdCeVZvXH4HzUuz4ohl0cbvMih0Vtr+ee53FHrbiW5Z7XMLINR6j+WTKwGdKaa
         iRPS4e7TbethMRid1CllT5zUVORX0GjVOPive2yYJIMYfcWNBOSn+gDHTqfZZjkRxWdd
         BxBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:in-reply-to:references:mime-version
         :dkim-signature;
        bh=WeV1zsCFRBumBHt5pZDCBKNwJ1QPYYaUXG8LiQ7ZJjg=;
        fh=A6VhHI7NKHnmfjjs9vgKiwsl8TnYIjA9XaJXQoRXXsA=;
        b=RWUlC94SPEbf0QnECDuStcGg3DMFUE2fA5gExYtaI/qW4TFETH6nDoUg1z41Vhu6yW
         +NsDtz9NSA4Bk7wCtECVeR50RaeZ9zQ6SV6afpQWIOuRFdHipaKB+O+MVwzsz3l8bw7Q
         92/uYGUEfsQ5+AcMEfpgzzFCf4Fa4iNob5JQlnSOMHQyg8oBvZa11eY5ulpX0GOXLHOz
         okpkh8PGEOGyf8OHt4u9xgSPUSnzSKkSZspQpU5z8hXeXCZ5KZP0sc1NP0mAqNQMzzNo
         T4BgatUcn50lJ4OaJOVCEuB8327TrBUO9ochBtgRlWtHjOcXbBq2SfbIBmlPmQ8TpdXT
         7x6A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791532775; x=1792137575; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=WeV1zsCFRBumBHt5pZDCBKNwJ1QPYYaUXG8LiQ7ZJjg=;
        b=hW7KYZ4KpUsE26D242Hi15qJKSlmOcy2mRrB7RbRmahywBlZSmgZDR1PKHAv+J9F4d
         oQAyiX/TF3qL83ZiFdiTX6R6x1J1MNUIUPtFuYmSGfi2K94jgfF/DN3p/nvlrqOgDIVu
         u6v2jb1Uc/AxQsWtfTT6sBop2f03pwL52BAhkulE811wXgC/AfZi+9tSyoFVZsFarL0y
         DYDd/BzWfumMxl2r9HxxY2Eglme3xMOUaWDhB+zNCSmNFQ/1KXEYzTXomFDy7JNS70CY
         s/grpyDOtr6nrOiwJeL+78agy2jN4ZyhcDoVRNmNJ79lgedtrRkNZlrhQFiDBVZeLEEC
         qnmA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791532775; x=1792137575;
        h=content-type:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=WeV1zsCFRBumBHt5pZDCBKNwJ1QPYYaUXG8LiQ7ZJjg=;
        b=KCox8vJH5Vtsx0bXP+ovw/PqUI9NxvhE57AyFMgzxpCYcsn0caPQcFllT4jLeQr3Me
         tR09mgR7m2f642zic7W4I2T/B3N839BfAd1sZKNeqTTWst1dajPUmENjUcDtvOlQ8y1q
         UikjYHMPclnL3QVbUpPCFKHWnm95Jj3DwuswUohn2mx0Ef7volM4gTBK0+c32TrEDVXQ
         vhwoXmoizAyIR8pM7MumJJUIRRCUB062XaDAQkTifCQwVVuFw1gmy3oUWePi3EnaztWL
         Zple0fksQ1i7VzCPi8b7zviW9FpOv5zV/QwfregqiqeFUrtoj1tg+sSjSKnXpD+aKU7S
         K54w==
X-Gm-Message-State: AFq9FYJtZVc1ag4yUrzc2RG2y/6jE+z1GOIRZeYKfxWk3QodXXGWfrzy
	J3ztiPLVLO9qd9eOKzxrX17R1/ZEk7cwjGROzAJ1U88CqjzqaOLCyIy6TuoJfi8jwY2xWlr2R8R
	HLOMPgkINPqBXTSFa/YgqzxJ9KSazhIBZbw==
X-Gm-Gg: AYBFou3xRLvUAK3+w3a9UZg6IPPuOEqfbLguOKHXqLcmEu0NQWy+/9jwTimjosra+RL
	iRY1lQNzEXhKNCrkukyjzsx/wrnJN3oQ0h/+0DAhH0p5q+oqZ8U+WyPjL3oyR2M3g+f5qS7bjZH
	thfH1GkFeQfoGWjs9mVm/KZT3rBP90ZsH8/y5osmFEkgZaJBlWB63JndOvVqwE4IP7AvFYjVEBZ
	ONsR3wpqkuizIxetkQXBPH7YH92rdvcNmaPAX9c7mwLN5vJoMU+YfnzW/CqraSEIcWGoLBuu0AI
	sJS+4hZk/V8/YMEFxmFniMEvv3JlE4D9S/Zyi7PRTbls6BUiWB3kQLaCXQ==
X-Received: by 2002:a17:907:9816:b0:c2e:378c:8ceb with SMTP id
 a640c23a62f3a-c31a9fa39abmr103143866b.36.1791532775339; Fri, 09 Oct 2026
 00:59:35 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20261008154729.77787-1-cel@kernel.org> <20261008154729.77787-2-cel@kernel.org>
In-Reply-To: <20261008154729.77787-2-cel@kernel.org>
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Fri, 9 Oct 2026 09:58:00 +0200
X-Gm-Features: AclHuK8MHpNlg_PEITDRkYW1ppvXcdL2OYS812yCHGOB88xO5V7E7RyIvb5f2II
Message-ID: <CAPJSo4V=NF29nFxjNza2sWe960zgLVvW4YZTT1n640otH8_1bA@mail.gmail.com>
Subject: Substituting WANT_DELEGATION with OPEN(CLAIM_FH)? Re: [PATCH v1 1/8]
 pynfs: add test for OPEN(CLAIM_FH) with WANT_READ_DELEG
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

On Thu, 8 Oct 2026 at 17:52, Chuck Lever <cel@kernel.org> wrote:
>
> The delegation tests request a delegation only through CLAIM_NULL,
> and OPEN7 pairs CLAIM_FH with WANT_NO_DELEG. No test covers a client
> that already holds a filehandle and asks for a delegation with
> OPEN(CLAIM_FH). On a server that does not implement WANT_DELEGATION,
> that OPEN is the only way to ask.

FYI substituting WANT_DELEGATION with OPEN(CLAIM_FH) turned out to be
a deadend, to due various factors, including:
- many nfsd implementations do not implement OPEN(CLAIM_FH) with
delegation "upgrade", and it depends on either delicate/fragile open
stateid updates and barriers to all worker threads in the client and
in-flight RPC requests, OR
- handling of NFS4ERR_OLD_STATEID handling in the client, which turns
out to be impossible because many nfsd implementations return random
NFS4ERR values instead of NFS4ERR_OLD_STATEID, or just  shutting down
the session altogether (NetApp).

Lionel
