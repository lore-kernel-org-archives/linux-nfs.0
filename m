Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2653914A82;
	Thu, 11 Jan 2024 10:21:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linuxfoundation.org header.i=@linuxfoundation.org header.b="XFqss9mO"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 51498C433C7;
	Thu, 11 Jan 2024 10:21:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=linuxfoundation.org;
	s=korg; t=1704968487;
	bh=KRTB7szqaD5RceYIxOt+TvmkK1Zx1Nsc+xAoCZt+oUc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=XFqss9mO9oKNzkWMNZ+BJS34Doud/qENsXY3oz/9w2oF7nRFnjjsgTQCXNQYYA4qL
	 OTIvz7mCLZWZ3lLb140muWFexjPzuCt0RGwrxCxgOAsWZRfWzaZhDLjDIlfiJA3YoZ
	 DrkcVSLLZkm7wGRmbHYn/XYWdcmdvvAh5haDT1D4=
Date: Thu, 11 Jan 2024 11:21:25 +0100
From: Greg KH <gregkh@linuxfoundation.org>
To: email200202 <email200202@yahoo.com>
Cc: regressions@lists.linux.dev, kernel@gentoo.org, stable@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: Re: [REGRESSION] After kernel upgrade 6.1.70 to 6.1.71, the computer
 hangs during shutdown
Message-ID: <2024011114-attribute-semisweet-788c@gregkh>
References: <58ac38ae-4d64-4a53-81e0-35785961c41c.ref@yahoo.com>
 <58ac38ae-4d64-4a53-81e0-35785961c41c@yahoo.com>
 <2024011127-excluding-bodacious-1950@gregkh>
 <3b8250ac-79e4-46d1-a508-5773e6330fb4@yahoo.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <3b8250ac-79e4-46d1-a508-5773e6330fb4@yahoo.com>

On Thu, Jan 11, 2024 at 09:10:39PM +1100, email200202 wrote:
> Hi Greg
> 
> I'm sorry. This my first kernel report.
> 
> I didn't test 6.6.x and 6.7.x.  I use only 6.1.x.

Can you do so?

thanks,

greg k-h
