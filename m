Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0402D3DFC8C
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:37:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788539832; cv=none; b=DSkt4huHGW1S7CriesnjCOZnlLTEmgghzg8/BiXqqKiAnNUfAmqrJ3xtmHVVXzQJuFzuT9NZbjc7JNvDuEs4hE2fHWmSVphdhMGzNf9hY3BJ6Zu9T7juFNtmre31Pn40GfF9zmG+bh1SpkKx9ipeggAs2BkY5NCp3o9HwXIY4/E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788539832; c=relaxed/simple;
	bh=Bkr8IRbbnhw66KtUv4N4Gjt+JVioGNpVucfqD8XeFh4=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=gs6NEE2OS7rZ+G4Up1Q2TSgUUI8m16SPrXJzeLYhrFpFGJ6Ttdq+DMWn+7j7gmN2aQDsVgfBFeonBB7oWn/A7ftHuJh6zTdKC9BoyFFk9KEayJ6Sd3UxjMaoWzruIhz5f4vRHATYAJg5DwCOcJL/GFiWbWFjAws+7Eog6vj8WwQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=OY/1o0hp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="OY/1o0hp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E3391F00A3D;
	Fri,  4 Sep 2026 16:37:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788539830;
	bh=O9tUCDYI4OUd+aaUzV45aMgp13zXJF/zoMyIMMAxa0I=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=OY/1o0hpE59qgVaMscsrMbNne3ePseeTCc9uf3qUxMc4ffypW6b4ipon9xySDWMDM
	 ZG7SXbNQzm7LpOpeseUHCLfC8Ax+9fRLx2f2g4zHD31gL4fT5zn03qwqwykk5cidxW
	 5wvvWW6d16K4YUZSjpysrWQbLnOoVPCGt6lqXzG0wdeytEJjlTqsI1ffKyCavE8gjf
	 Q9mZvGpflEv1IP0YOT6iaralfZJCW4nIj+CfuddmnzNzxzhmOBfM9w2LAag214QHWc
	 iJ1FLTO0FbEf2WR0KgQ8T8Bck8qIc0YNjxOU7jvak4i3JAGID40jetq+4iOU35Cu+2
	 AE1s4P0vyAI6g==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 35006F40066;
	Fri,  4 Sep 2026 12:37:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 04 Sep 2026 12:37:09 -0400
X-ME-Sender: <xms:tfOaat4uOyxEwWfoUOn1URtqN7jLpSr4sz4wC6cxoWFnQm3eRPH8sQ>
    <xme:tfOaals8hZVIgAGn7Zdg3YLnFQvhkAYyn8PWikBNdDBI1klw7jjua7cDyd19Gc3Ig
    hb4vxo-J8yW5y2PH8rRBWr0r-6LdsBhF0auW0b81heCH3ChB-ksLLLx>
X-ME-Proxy-Cause: dmFkZTFiWN1mgEv64BBLiF6aIDEmvw5PIqHtniSSrsJjg2PAqmAO9figg6MA/VWRne5neh
    U5CNdGHJwKekhwt1mOh9EuIm4mMns3Pdoq7NR+FoqYhqVYBrm818GasLgF9tRX/DFuBzy9
    BHj7eG3vIoPcdLIez/zFQcF8q1D92FU4UAB2rCrA4cdEbWpv45xBXMTisUHgLtjGDzu0bF
    ajw/2UclNNr6lLwd/5gp7e7EiZ5d7wXG7v80LxEcQz+fbKQpD5ahPwl8LroeNZfMg7tJiB
    mmRSkJGReleKrjr0SSQ/MuNoCCKr8AxfYeX3qcXHjwolbs/rM2mVVsPQN6BhYBv2Ha/Wbe
    ExDig03093Gx1r6xej4sVIkrCisnRoJqE5BawgSeT5c6Lycpb8pmiZKbI4z7tJDTvtJs/6
    FjHhMUwEEbEJ8eBnwM85B7Hzuz3SKom08Gp0dtzemGkfPDMxmAmG8FmEuVNEOeI0knVmzq
    Z7bkxFldpJXWSTt/tS0BW5gozSae9cd5Lpp9PUVH4InxPKA4sCRPH4FrNy0BLbz9zOBzKG
    GLx18tThJ9l1K4VGdmjjHATRK2lC7rOpIG2Tb2LMF3OZFVsJmwuJEKEFC4fIUCRqjKZmC3
    W1DhvMe7fmwwYeJoMij1J0ZQToYMkIKqMona5bgpfBqweD6qtANzjkLWXFIQ
X-ME-Proxy: <xmx:tfOaao_pNKlqc1Lug2cLEfN3XPe26apLcE9bwkh7k4iNxJnpyLWFqg>
    <xmx:tfOaamRL5ZpPack-5gvn6EabE7F8FO4CQm45inWuMGJNiKaO-HkAzg>
    <xmx:tfOaanl53kESLI6he1HOaOJhx1bb6agodagUO4wbMBr8txpJZ1QStQ>
    <xmx:tfOaapWs7rU7wHj0e94V92NIfleRrWYdHdCVmjYHy888RGx0M9b_aw>
    <xmx:tfOaakd1Batdkobbc4vDpwZVdjew-_G6mBnjtCWhhlqd6aBYTE2dpd_e>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 04D057811F0; Fri,  4 Sep 2026 12:37:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A2Uxtb9eUQMg
Date: Fri, 04 Sep 2026 12:36:47 -0400
From: "Chuck Lever" <cel@kernel.org>
To: 
 "Cen Zhang (Microsoft Security FORGE Labs)" <cenzhang@linux.microsoft.com>,
 "Greg Kroah-Hartman" <gregkh@linuxfoundation.org>
Cc: AutonomousCodeSecurity@microsoft.com, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "J. Bruce Fields" <bfields@fieldses.org>, "Jeff Layton" <jlayton@kernel.org>,
 kys@microsoft.com, linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 stable@vger.kernel.org, tgopinath@linux.microsoft.com,
 "Tom Talpey" <tom@talpey.com>, xmei5@asu.edu
Message-Id: <6962f43d-10c4-4530-807a-def951c4eb9c@app.fastmail.com>
In-Reply-To: <20260904151213.44891-1-cenzhang@linux.microsoft.com>
References: <2026082828-palpable-dingo-241b@gregkh>
 <20260904151213.44891-1-cenzhang@linux.microsoft.com>
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 4, 2026, at 11:12 AM, Cen Zhang (Microsoft Security FORGE Labs) wrote:
> On Fri, Aug 28, 2026 at 07:29:11AM +0200, Greg KH wrote:
>> Please use your microsoft.com email address, and not a random gmail.com
>> address.  It's kind of odd that Microsoft would have to rely on Google
>> to send kernel patches :)
>
> Thanks for pointing this out. I now have cenzhang@linux.microsoft.com
> set up and will use it for future kernel submissions.
>
> Chuck, since the patch is already in nfsd-testing, please let me know if
> I should send a v2 from this address to update the author email.

I don't see a need to resend, but I'm sure someone will explain it to
me if I'm incorrect. :-)

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
