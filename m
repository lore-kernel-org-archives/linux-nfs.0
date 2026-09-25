Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BAFCD4CE672
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 17:54:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790358847; cv=none; b=uKlvqDGy07D1X3bNc9oXYf7YY/3Hb+kxKvwO7OrPq3sCa/1Xs40XKXzP7S/b7nH/EJxOK3tA8F0KSNj8FK3GVo8KoPueVb7qKiKblNcrkcTKXoebUUc0VlRg/TQfl7jZ/feO0pKFvdEEi6wk/Ob68wHyxEL9EJaGMpSd3nWqfSE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790358847; c=relaxed/simple;
	bh=H8K/izHnb/t+VQrXJuuX2LyWOPMGgJn+U3btMq6rAys=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YKdotzMxKUChJt0mZCvAx2zUQDyaaBH+leLBe+wGkAnemSEWh3Rzp2pwZHOYXYBV2pSTyMEkP+Pnawze0riHLEgDX4jmlJvB1bNqnUYqaLSmaMNJ+wMqLdlnSeZToo0k6gmO8Bx/QCufbQxaVaHUP7DyLqvKNs2bhRuNfNScMrc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=c/xLqRwa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="c/xLqRwa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBCEB1F00898
	for <linux-nfs@vger.kernel.org>; Fri, 25 Sep 2026 17:54:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790358842;
	bh=r9m2taVbcymIr7HiW16ZXY403gMYBnVXIHlA5v9kKnU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=c/xLqRwaYHWIBQZJi+fh31k2HQ3z92pRscQogtPeml8AAMe11kleCEXZUWEiYNVPT
	 dmMJXird1BPvVePGv1xQl7hDZ9zExKelNxTsDj9kuGCeJQt74cmYGER6I7KXALb0ew
	 mKgqy3H5OAXPOliaWhkwu4yIzckM591FFFiu7O/Dm7xx2WmpcY+nAZhB0KxaS3jiN+
	 9lql/R0JjAR4WZWkQ788iywNf7jUOQi+y1LlCt4MrIEqRbXFu47Vwh8XCeC3SYDuKf
	 Nj0QUSMhbu6pg5p2XF3tfbnaBA2uxN/C2JnyXBvhQjh4+zLxZdaZfpQUW1Zt8HX+Rs
	 /vY2PSy1JC++g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 90D14F40067;
	Fri, 25 Sep 2026 13:54:00 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 25 Sep 2026 13:54:00 -0400
X-ME-Sender: <xms:OLW2asUGGFg-laKEcNk8bwDbwBSKGofOuAGY7RTl1WMR9kaSZeP-8w>
    <xme:OLW2arazegeRLEP11it7itDtQFZD0aQBL2Dk4EtKshpjD7i5OvPGsqucjfXu6dSaZ
    IRNftKzYiNxwBU-_0z6mK8d2j73LBJ6du0qXMFDkXtkFRb78L2ji6kJ>
X-ME-Proxy-Cause: dmFkZTEJu9UcuBBdUygtQ/lznELDpuYZ3Fi7CPd/04ubOKOIHU+d/+auW9lwC9XbQG5Vfd
    e5CfcCpckM/EqoHJmR3Y5UMBrZzCpNyCphLuR0Oo6yaddjvgDqRobfzzOLvd2X9Ev4gmpX
    1/+FTa84jrColA9MvHloSzzbq1L8d0YxUdwZvGIuVzbXz/UuQY7Z1/EwHOeefdIkB4N+JW
    gsntgNHtFiR5+xQBZtuy6NghP+/mFswBbVdvYr3DyPZtKnFo8o2Dmdc+aHkk7cpkPOFZxR
    ueP6HVObhynVX6vVSlNdVZlQnHEz+Egy+e271vQVbUMSZQOscXOWhUvvNwVX6q9g64USlV
    7Il0STlnVqE1QQx/tOg9xyNVvqtPqzJ2ejnOzXy8gIOOe9T1Ae2RmMQOB8JneI3NNTo2ei
    VhU1Q0vgAk7CpVMweO2p0AxChy5cEPbwCwJJZtNYw/QwABQzWzTtC0IU3GbGtV59efaDqP
    94znYanPdmOd97xlnJe6929FfgoEbSp3LFPhMi8S9f3cQ4qrwR5TPFvcNOkteGG1bB9SxY
    uJIaYa1PY04NsZawO5f5vXI7AZxM6RV3HTXmi+chxiuc0WDzYWKDocHKq906qavvH5KrdD
    O6mIxC8savnnjim21VUJV5UeXf6QWxXUZHjpFf36QkFYeLgta+4FdASk+8og
X-ME-Proxy: <xmx:OLW2ajCptXoL4W49tTilF49A6u2vRDr5vHxogjYm-Z1XQGeFeqcaBg>
    <xmx:OLW2andydDXSLERGyM8zS-LQVfJ5i3WYblI7UJh9FVwGaFvALrZu3w>
    <xmx:OLW2amIk5gL06MpXz92o7APQswOADzUD_rpbIcj9xzurrL_HXFLt0g>
    <xmx:OLW2aid1nST7EK1-BRMxFGbbkOtirO5Hy0o21AOQPOzuUckOGTrADQ>
    <xmx:OLW2al2e1LtQFuO3SpnTNrt7Uo8lUJLok5pfaTbjfdvfL9D2jRKXGDJJ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6AF60780070; Fri, 25 Sep 2026 13:54:00 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ayf7ehSQeGM-
Date: Fri, 25 Sep 2026 13:53:22 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jasmin Dave" <jasmin.dave.math@gmail.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Message-Id: <760c816c-96c9-43c2-a549-16c7049fc1cd@app.fastmail.com>
In-Reply-To: 
 <CAHvsQGPXA+boPzZ_87XoxFFSn8-2TNhMXnmR9Rd+jB9dFcF+Kg@mail.gmail.com>
References: 
 <CAHvsQGPXA+boPzZ_87XoxFFSn8-2TNhMXnmR9Rd+jB9dFcF+Kg@mail.gmail.com>
Subject: Re: Multilayer auth with Linux NFSv4.1/TLS?
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 25, 2026, at 11:55 AM, Jasmin Dave wrote:
> we have to add multilayer authentication to our department NFSv4.1
> servers. We already deploy krb5i/krb5p, but due to gov requirements
> around NIST2&friends we have to add another layer.
>
> Can NFS over TLS help with this? How can I set this up?

RFC 9289 specifies RPC-with-TLS. As an RPC-based protocol, NFS utilizes
this RPC extension to protect communication between NFS clients and
servers. TLS provides two protections:

1. Encryption of RPC traffic on a transport connection
2. Mutual authentication of the two peer hosts

It does not provide any authentication of RPC users or groups, as
RPCSEC GSS (Kerberos) does. Yes, you can use both RPC-with-TLS
and Kerberos at the same time, though there is enough overlap
that it makes sense to do so only in narrow cases.

Help me understand what you mean by "multi-layer authentication".
What are the underlying requirements?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
