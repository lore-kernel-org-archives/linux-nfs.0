Received: from mail-oo2-f38.google.com (mail-oo2-f38.google.com [74.125.231.166])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AA9621A42D
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 08:40:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.231.166
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790671205; cv=pass; b=p3pfiaStY8+rCBdyjjRXJ9rQ8ZvHNm0uQrR903/bWXTjT0W5HuKR1ZvOkKyK5dmUNRkESTfhTBEKug02uXtXV0M48SqnL3WS7q7yu3QIfvfHjlsv2Hc5G/OjmHovAAgNbRFwVng4fFkCMqCJ05kKrGMUjnuwpmgaB7RwFJSp2W0=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790671205; c=relaxed/simple;
	bh=8n1Qj/+Qq02fuplR+ddKhrf3waXtS9+V/emQIw4/MAU=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=SBfA5ENn5fL9ayxYDLGTaJMWdi7IaQXNSE+yuoFhLogxB/MNIWBt03TbitdBRX2ko7KJump0CE85ARSXT8n0k/gOlr4C6fP69zzBhvIbZGmkXnQfTYyoUJJoIMIm9sXcUiZHgzgkQHTq+oY1qVmbTUpIaPyTve4Iud7R5p4qraI=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SEyVkJoS; arc=pass smtp.client-ip=74.125.231.166
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SEyVkJoS"
Received: by mail-oo2-f38.google.com with SMTP id 46e09a7af769-8138dddb94bso2721513a34.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 01:40:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1790671203; cv=none;
        d=google.com; s=arc-20260327;
        b=a2qGXbFmD889iVUijD8q+EY8CzOs82JvG8NMCrxO3UDtseuYM0juUIhCvgcbiwhPDS
         8y2ahOubcUNj50Edgom2P2hWwpeE0cdMHvpUnRWxtlAKbXxIxokkauiaCWDFu03Pbb51
         V8pKNE9uAn4CC8e6FDTSAJgRAE6mGaBbrspF6+iQDqdnOQre9obqKprCdaQg2n1dxTFv
         whZBULmsmw4q9GnNmqApkz93pj3ePwvusDyOiyOwL9mlAYvMKgkRtaK2lkSiXpb/l2si
         5Du6oKIhqqfrkYmgrvuR3XaSUnscz6RdBaApdK/GMMYMN+zAPmeN55k7GnIK9Zcs67Ll
         L9vA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=8n1Qj/+Qq02fuplR+ddKhrf3waXtS9+V/emQIw4/MAU=;
        fh=A6VhHI7NKHnmfjjs9vgKiwsl8TnYIjA9XaJXQoRXXsA=;
        b=nUiLKVvCpDag+N96GAVE3eRTatJk5qiX7xqLuI2gFg8Ijj1a4jOMkRUm7cEsBpVU4t
         Oj8B8N+HskP0cGwLByxuZxoXG3XhT03nzPyjqQOxW3HW8lK1sVyJFz4MqHf/HQKdJTBe
         hKJxijx2StKbhXqmVs+1wy5rX/K3ioat4Bcj740mjBuqAFpRUyS5ZCvE+oPg84AFb6Pu
         7Rc/tfcCznLwQe8tYWvvzLkij2rIFcmw9qhertr5O/IEBj7e6v23FtPMR40Dw0N3cQW/
         4Fc0lD2LIToQZUgdt2RJFTHqc/D+h6pe0hvKk845+MWePbY+SY6/+LvxjZXmqACU5v26
         MRxQ==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790671203; x=1791276003; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=8n1Qj/+Qq02fuplR+ddKhrf3waXtS9+V/emQIw4/MAU=;
        b=SEyVkJoSL3xk72WpMCWe4pnLM8urG4W+fiflI3McZbkkOeio7fn7RMRsXQ4PM/bEPZ
         43fZIZMEANCNigL36M8rH/I1NPRdlUxG4rNBSSuU52vIpNgOggxyymqfa2JbsbUlGLkr
         Kx6pvuVWU9+Q4XvI7pQoVWIIzSx0Cg9SAyTlBkRZfRPe+qpE67LnQkka9fdef6N7aveb
         7nRLHmGHPCxjFChQeSF/YKGlIusO4KBdOulJgrRB2kFl5FdI7aFwA5bEXT08rV5XgOV1
         tuBAx1yM1kQBfHvr1E8lydihDkLZbvMYTFV2ETk0L44uD5E49zk6dlUeyhKwWCvo66MA
         NfnA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790671203; x=1791276003;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=8n1Qj/+Qq02fuplR+ddKhrf3waXtS9+V/emQIw4/MAU=;
        b=KtlXh+Gq+TnM9EusOuOvIMMtpHhxUOkiJffCSS9Bk3dLQGoCZ/ej5qMFGrW8Rv1Szz
         8AfZcoM+IPMj9M9ZNm9ElJ75X/V9UkhYItLMPiGqdhpoZ8s5htzbKihCUbCfazJaPi5o
         sCztcMKhjkuFyC0S5TKcVHwpZL2ECKJbMCfYh35GZG9D2EybvODzKXqm787pwxPte/iO
         xoLsSEXQCNew+xIh4V44nohmYUUwH16zmElhagkh5qYt1yHLx33ZNUPiRYWMkECPSRuS
         snAdwDJbrfSIkaYChuNMS+FwR5o0CuBhptsTzIooughlTAd49GlhymeXdncpoT62gGaW
         OtKg==
X-Gm-Message-State: AFuF++l+Gfq1kK+FAmJd3sFzxHUH17Sf+KMzwxxzeoHkD34GzWOFg1xY
	FzZgKBLpt+1bKgXbVOgUKRjJ3UYJU8eJbxoN9Xi02A5LtYMC1zWAtwHHPmzOBvK5ArQod2k6TMD
	qTN0PBBgdKv7aEuXBOX4o+ordWvZnfh2S3SGaiAk=
X-Gm-Gg: AYBFou2cqCoIvfB6KgwmFOGkQUmSqfKh+H5pUtvmVrmoFbyqVG6ZhpfiNIPr4hK9SHe
	knwAaMPXq/SqE40Vyqxk7/3+7OVzkha4ZXvaHARakBlZPeF5BABwSBIYg6TgkCEGsB7C8YBkV+I
	W1cjg0Vyk4RSarg/d51Bd4EzmE41v0mNN3aVMSJ68ZCGv3dOHhMo2+2zRn3HoWgcN6khRJkFwGi
	m+YpwvNlaKL87J97lNq220pHSRcvVuTg2fIsnEI0aUHNsuvqTRD+5789wvRLXilsPs8UpivWFNC
	1Fp9/OJoNNDzcLLi0P1LZuhWBEPac7xU1I43wqE7iwHKGsdSl2qsfEw=
X-Received: by 2002:a05:6830:6b07:b0:814:57a9:4243 with SMTP id
 46e09a7af769-81782b8512amr16009125a34.17.1790671202933; Tue, 29 Sep 2026
 01:40:02 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Lionel Cons <lionelcons1972@gmail.com>
Date: Tue, 29 Sep 2026 10:39:24 +0200
X-Gm-Features: AclHuK8Uy5j7RcNSwPESZWoO3wxDh-Ue7GZHwiP42CXvXvs1JymNPKAfMz2Tgro
Message-ID: <CAPJSo4Xs_J=Lx06kohor237hDLYbuYAhK9FrvQEBxvfAttE1Hw@mail.gmail.com>
Subject: Linux 6.6-stable nfsd diagnostics why NFSv4.1 delegations were NOT granted?
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"

Are there any suggestions on how to get diagnostics (systemtap ?) WHY
nfsd NFSv4.1 delegations were not granted?

Lionel
