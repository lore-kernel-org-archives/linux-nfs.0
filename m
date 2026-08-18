Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2540A533D6;
	Tue, 18 Aug 2026 17:42:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787074978; cv=none; b=Pxc7iuExAqJ2HchI1a53qnCU51N2O2Ii9TsekRZvXeI214g8eq6qDO1LmhnRAIJsmMb4DB4mtGP7tfVa+WCITwFC3tMt+nAaLWqZ7Y+UAYOCigLpodlloJkuZHymcyjfIpiYU5IsN4CbZhUp8jcOdlwyk9Gy6UBC0m4QitLNS18=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787074978; c=relaxed/simple;
	bh=O8KaTOFv46F3bnrEoLA5Ex5inSJyrwrbmolDkiWDfEo=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=cAejHBnc0q+AKZ5cx/OFnAIrvWDcUA17lYhnbBBl7VJB6BI2CDLA672YC0JATR2dmPRUELzCU7cip/zJsEDdglTxPwp+HsWLEie7ou8R4RTqChgvbMDy3+hWOZnikH+ORlrBpKJRJBHpev6jq0gm35kGuHZI4esTTa8lQOIR7lw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bZiXmP/n; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bZiXmP/n"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD5A51F000E9;
	Tue, 18 Aug 2026 17:42:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787074976;
	bh=kQ8QBSt+g50Q8WDOGTP2v+pmrbFoNcApqCkakp+FL9g=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=bZiXmP/n9GUc57qZ1BBO05U6+WQ2BDYG4Yn8+J4Q0wrLow9G8zE0JwCcNmr2IkSvs
	 2TWTcU9C4l/Ber2k8fWCWr93uHaUioYQW7fkDt4V41GJbqbHukansxD020Ypo4EFOh
	 NTnMFtdl5u1ycskMZup/c/n58LKU2HSTnvNWjTca/3annUQH/hZ+DXTcPy+YT2xhug
	 SdUTTKK83JWp5I80vP7fOXkf4usPsToB8UXISKv1J/nme+Pxt5MIrW7r8zmX9zQowf
	 T78BfzDHRMqMkVSZtZaaUHVu/fY9S8O4+4w1qa0q8TG85AJGjZtDYmwAtpLg9mFWa5
	 v0+moV6nS6wqQ==
Date: Tue, 18 Aug 2026 10:42:56 -0700
From: Kees Cook <kees@kernel.org>
To: David Laight <david.laight.linux@gmail.com>
Cc: Mariia Nikitash <mariianikitash@google.com>, trondmy@kernel.org,
	anna@kernel.org, justinstitt@google.com,
	linux-hardening@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, nikitash.mariiaw@gmail.com
Subject: Re: [PATCH] NFS: nfsroot: replace strlcat() with snprintf()
Message-ID: <202608181041.0619C92@keescook>
References: <27956255dde39f58d73a7b51cb53cbe3d7804f54.1786411026.git.mariianikitash@google.com>
 <20260818095548.27e0edb2@pumpkin>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260818095548.27e0edb2@pumpkin>

On Tue, Aug 18, 2026 at 09:55:48AM +0100, David Laight wrote:
> On Fri, 14 Aug 2026 00:28:45 -0700
> Mariia Nikitash <mariianikitash@google.com> wrote:
> 
> > In preparation for removing the deprecated strlcat() API[1], replace its
> > uses in root_nfs_cat() with snprintf().
> > 
> > Build the separator and source string in a single call using the
> > remaining space in the destination buffer. snprintf() returns the length
> > it would have written excluding the terminating NUL, so comparing the
> > return value against the remaining buffer space preserves the existing
> > truncation check.
> > 
> > Link: https://github.com/KSPP/linux/issues/370 [1]
> > Signed-off-by: Mariia Nikitash <mariianikitash@google.com>
> > ---
> >  fs/nfs/nfsroot.c | 8 ++++----
> >  1 file changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> > index 432612d22437..e951fe731679 100644
> > --- a/fs/nfs/nfsroot.c
> > +++ b/fs/nfs/nfsroot.c
> > @@ -173,12 +173,12 @@ static int __init root_nfs_cat(char *dest, const char *src,
> >  			       const size_t destlen)
> >  {
> >  	size_t len = strlen(dest);
> > +	size_t remaining = destlen - len;
> > +	const char *sep = "";
> >  
> >  	if (len && dest[len - 1] != ',')
> > -		if (strlcat(dest, ",", destlen) >= destlen)
> > -			return -1;
> > -
> > -	if (strlcat(dest, src, destlen) >= destlen)
> > +		sep = ",";
> > +	if (snprintf(dest + len, remaining, "%s%s", sep, src) >= remaining)
> >  		return -1;
> 
> I think I'd have gone for:
> 	size_t len = strlen(dest);
> 	if (len && dest[len - 1] != ',' && ++len < destlen)
> 		dest[len - 1] = ',';
> 	if (strscpy(dest + len, src, destlen - len) < 0)
> 		return -1;

This is valid, but I just feel like %s%s is more readable for what it
does. You've open-coded the first %s, and the ++len's interaction
between the logic and the argument to strscpy is subtle. Since this
isn't fast-path, let's use what Mariia has proposed.

> 
> Although it would be better as an 'add_option()' function.

If this were done in more places, I'd agree, but as-is it's pretty
limited.

Reviewed-by: Kees Cook <kees@kernel.org>


-- 
Kees Cook
