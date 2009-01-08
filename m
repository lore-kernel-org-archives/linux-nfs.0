From: Felix Bolte <gockelhahn@hotmail.com>
Subject: RE: exporting loop devices / fsid issue
Date: Thu, 8 Jan 2009 17:59:26 +0100
Message-ID: <BLU106-W451DF9569DB8010229EDAAC9DC0@phx.gbl>
References: <BLU106-W57D668101BC034E6586C60C9DF0@phx.gbl>
 <20090107205419.GH30538@fieldses.org>
 <BLU106-W41CBED673D264FC30BE28AC9DC0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from blu0-omc3-s1.blu0.hotmail.com ([65.55.116.76]:40917 "EHLO
	blu0-omc3-s1.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751692AbZAHQ71 convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Jan 2009 11:59:27 -0500
In-Reply-To: <BLU106-W41CBED673D264FC30BE28AC9DC0-MsuGFMq8XAE@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


hi again,

>> Anyway, yes, the composition of the filehandle did change, and it's now
>> calculated from the contents of the filesystem itself using libblkid.
>
> what was the old behaviour or library, which calculated the fsid from the major/minor device number?
> can i switch back?
>
> btw: why was it changed?

by writing my last email, i got the right idea ...

ok, i looked at libblkid ... ( http://linux.die.net/man/3/libblkid ) ...

it cannot find any differences between my two files, because they are the same ...
they will get the same fsid ... thats really bad for me ...

but libblkid calculates the fsid on the basis of labels or UUIDs ...
fortunately my images are formatted as ext3, i could change the UUIDs on both images(partitions) with tune2fs

and i have to say ... it is working ... :)



have a nice day

felix bolte


_________________________________________________________________
http://redirect.gimas.net/?n=M0901xLSVideo
Welches Video willst du sehen? Neu! Webweit Videos suchen. Hier starten!