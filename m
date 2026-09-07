Received: from mail-ed2-f12.google.com (mail-ed2-f12.google.com [74.125.228.76])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72F0D43B3D5
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 11:53:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=74.125.228.76
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788781997; cv=pass; b=B+PgUXwwvoqK82eJffEtDJhLGu7vpTPorsE/ySicDSeqVygVXRUGt0KoSN+7yO8gqvAIcXmIOfOUbyKw5ImVedVTY++GdQLRLD144Zr/BQEDZuAyUWohwgXFapXe19seCB1wOURIUDQkdQ4FAJ+UgDkPmwCvSledYKn2NP7In5Y=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788781997; c=relaxed/simple;
	bh=iZnY1Ei37rZ7msN5aXR3cHW03yILS3CqMQdflPo9YR8=;
	h=MIME-Version:From:Date:Message-ID:Subject:To:Content-Type; b=MRfd6tE8FJjInD3RZgtTgB/2SYS1q9B+emr21FQqx6Efhzuj+5whXu11mfJ93+XUOleM2bW2OHUXs9c1Op/bwTia5ftbsxPFRpH7MwMkZObcKH7Mq9u0Hi4EURe/hEo+dY3iYOi1rDvauKTbXPECFNT7eG5j6KIqousYHbEsaog=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=fR5yLjh1; arc=pass smtp.client-ip=74.125.228.76
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fR5yLjh1"
Received: by mail-ed2-f12.google.com with SMTP id 4fb4d7f45d1cf-6a6056be4d1so68706a12.0
        for <linux-nfs@vger.kernel.org>; Mon, 07 Sep 2026 04:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1788781995; cv=none;
        d=google.com; s=arc-20260327;
        b=AsApMxR72kSwVjI0sFSALg8/tFJ7XY5enY83sTAf/qyh1Gnh+jBzhyoUcRupVFJAns
         K3YpMalyS0VKensYKgZAVaaG1YBY1Qwvi7MUDkTyBomrghCt9ubhR1KfidsD17QKlkwn
         cb/S+DOmOlf9/6Pa+5NdHwTPW2GjfYWxS6FhXirr39sOnrV1nfwqZklxkKpkUhqW2Olo
         VSV5g8eR1DW6fSuQTe6FBybRccKnobhqvPJwfvJ2yDgLqawJyPtd+V3CAFWbrcLDDnSP
         uHqbA5DvU0GvoKFOtrj3a/q48S9dQEK9ggehzVFMHkZHVk4+ZAyy/nh+1N3Nfqhfk3/r
         xNwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=to:subject:message-id:date:from:mime-version:dkim-signature;
        bh=k8pP7sJ8201wtS3KMZULVp5ue2oDKolayxqMvoEbAUw=;
        fh=MSjvmYgxjxAFPAmh8KDxavAuZVLcrdWDy6bDneDgDXA=;
        b=KedVzUng32S4xALZh3JgNpZNE9DHPXylZMfM9R3IhjbA0seci2ANjujKkFewoN8RG+
         arLCQ5/3cHfrGY+m9EnJp+JEJdOcQyP4rfQi0GPnpVbweIddhtu22zL1UmZxgh4ybNwf
         vqbRuyv6prUCdwElracss92rHTGCyvJhLZOkyjLrBAJt7kzPJo45XaAtYbSVGTctYzHu
         h2nhJxrImUaVqRH+oinmW0rpYDEz9ByPlN/f2wd0Uy6NzMgpNpzg3YElS/LfTX5MZRAi
         1k3dk8a3ITrRRCbWgLAJyXm3cBGrVrf7R1XWg2zgfqz3k6j4vIdMP2AYRlC6CJ6m3btq
         PE0A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1788781995; x=1789386795; darn=vger.kernel.org;
        h=content-type:to:subject:message-id:date:from:mime-version:from:to
         :cc:subject:date:message-id:reply-to:content-type;
        bh=k8pP7sJ8201wtS3KMZULVp5ue2oDKolayxqMvoEbAUw=;
        b=fR5yLjh1XzJlu60DTS5k7Hl/9OzQlr2dcp4vaVgbIiIZpZZwcucc9shF0LIvKXaLtB
         hETAnhq4hGGuHBeu0OilU2x5/ff8GQ5/LQnoXsiYKIfGg0XSA5/X9dt7LY/S6DQBdCDu
         b1KYZdsE9QHJmcTiZxEdPiAB1hygm5uU6Yn9xMYRm8HE8bFwuFUDl1tAr3eyMSM2Hv8I
         oxOwySyZdHWQAaDjmOEWMDEhRCrQaKTxPssEqGtAakJm2DEYmaL9nUgENVub3IwdGIoQ
         OShry9x/1ZBcFfubHEFS1iSy8HBSo2lI8xoFjvFDxWMMk1joyPTibDn1ncu4UaN9hNvP
         mMBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788781995; x=1789386795;
        h=content-type:to:subject:message-id:date:from:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=k8pP7sJ8201wtS3KMZULVp5ue2oDKolayxqMvoEbAUw=;
        b=dAUDC8MzI10W23d6R7PernZEikf5NH9oCvcFuxN3PCqQeWaWUmzdhOGKMBL0N8a1nP
         60XbEhYcNWNPqLtNrJVzoHskL9wODiohhG2De5itDapkR+AJQJETt59elVbiPl6OfWba
         2ucnDcXIe/obcJJS38G2bzZiDk7IQK0SBEVwISULbHe0O+/bajWZQN6GXnEKVjQNg+GX
         dLZ4eSzAjWQcsBfcqHfkAzTMvm7O4GDPgHQr8llDpYU26fXl5lr5CrUFbmhGUBmEQ+GM
         BuBqjEHE4QCrDa9w1iAUPONlTv+iAw05oodNO4fO61qj/6RRPAiZXhqYXOeovRHg1rHR
         QC6g==
X-Gm-Message-State: AFuF++lS4bkMlv611SaLVJCC1AfcINngivrq3juyacLW7TaTcYk98ZGV
	we5FTFAhRvSIZlEAg9svr44Vk9B9tuuYAtkqJMFUFwTIt4Rh6BL413sQuID30o3pVHa/enzsW7d
	bFrNpXZ0KM3k9S9Vqg+dOtYn5M9tH2lyOwg==
X-Gm-Gg: AYBFou0vaXX0Hs2rGvVY+NvkJY6TDMQtPYeAXi68oHE7Oq2dCMz1oesSsdsCzDoR4cy
	BgGsheQlM/BrK7adHS8HuRpbkVD8EH9t1EmLPJunLxIpj1763QuIwz7JmYDbLoz5B55rhNEGsCx
	ovw/ynpMgDrPpoB23ipBASEkoD/pmXv1xv2kpp2BfAcdJRfA9o03HQX+YJyTGtKsY1GstDxV5PI
	3405V0/mEY3Ur8wbdnOfc9omOGdU+26b525oqv8b417EEKF7PXiRXBWGCqUc/xIyKYhM7UuUJ/Z
	1OqSbKFGndxG8FWY95OSkGNoV02xhOl56QO/m7Q4Ulg=
X-Received: by 2002:a05:6402:1906:b0:6a6:b2b9:61fc with SMTP id
 4fb4d7f45d1cf-6a82fa3b6f1mr196179a12.16.1788781994524; Mon, 07 Sep 2026
 04:53:14 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: Shyam Prasad N <nspmangalore@gmail.com>
Date: Mon, 7 Sep 2026 17:23:03 +0530
X-Gm-Features: AcwNN1W5kJ-vw1BkW7IlUfU1L9-26NFwyplssvlZWvOgxfjaJw1PHOi5z8ZWcC8
Message-ID: <CANT5p=rb=HJsFPrD0swPi8D8LzaodTvKK=M6xwR0SvtK_YaLRA@mail.gmail.com>
Subject: NFS strategy for large number of file opens
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Jeff Layton <jlayton@kernel.org>
Content-Type: text/plain; charset="UTF-8"

Hi all,

I'm starting this email thread to understand how NFS deals (or plans
to deal with) workloads that serially do open/close calls to a large
number of files in a directory? Think about a use case of tar of Linux
kernel source code on NFS shares.

AFAIK, local filesystems fare well for this workload compared to
network filesystems, as file opens are local, and file state is
maintained locally. For network filesystems, each open needs to go
over the wire to the server.

Has there been any proposals to improve perf for such workloads?
Could there be possible extensions to directory delegations, that
could allow the client to make opens async and batch them together to
the server in the background? IMO, the challenge is that such open
calls can fail. But can the clients be enabled to do many of these
failure checks (for example, the client could be allocated quota for
how many files it can create, be allowed to cache file permissions by
delegating them etc.)?

Looking forward to the responses. Thanks in advance.

-- 
Regards,
Shyam
