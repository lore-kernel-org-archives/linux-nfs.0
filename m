Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acheron.ifi.lmu.de ([129.187.214.135]:38120 "EHLO
	acheron.ifi.lmu.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934035AbbGVMOB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jul 2015 08:14:01 -0400
Message-ID: <55AF8907.1090807@bio.ifi.lmu.de>
Date: Wed, 22 Jul 2015 14:13:59 +0200
From: Frank Steiner <fsteiner-mail1@bio.ifi.lmu.de>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: Are there really no server-side mount/umount message for NFSv4?
References: <55AE4FC6.6050001@bio.ifi.lmu.de> <20150721160338.GD11050@fieldses.org>
In-Reply-To: <20150721160338.GD11050@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote

> There aren't any mount or umount calls in the NFSv4 protocol.

Ok.
 
> (For example, an NFSv4 server typically wouldn't have any way to tell
> the difference between a client that has unmounted and one that just
> isn't using the filesystem right now.)
> 
> If you could describe in more detail your use case, someone might be
> able to suggest a different solution.  Or it might influence what sort
> of information the nfs server exports to users in the future.

The case where we watched the log file is very very specific and nothing
that could not be solved otherwise. My main point was that we sometimes 
ran into "could not mount blabla" on the client, and then the server 
often gave a more detailed messages pointing us to the error. E.g. in
NFSv4 we made a mistake by exporting our /nfsv4/ root, bind-mounted
/nfsv4/x/ and exported onlt /nfsv4/ and /nfsv4/x/y to some client.
Without any helpful error messages it took us some time to figure
out that we had to export the whole bind-mount /nfsv4/x to the
client or make another bindmount only for the /x/y/ subdir. 

cu,
Frank


-- 
Dipl.-Inform. Frank Steiner   Web:  http://www.bio.ifi.lmu.de/~steiner/
Lehrstuhl f. Bioinformatik    Mail: http://www.bio.ifi.lmu.de/~steiner/m/
LMU, Amalienstr. 17           Phone: +49 89 2180-4049
80333 Muenchen, Germany       Fax:   +49 89 2180-99-4049
* Rekursion kann man erst verstehen, wenn man Rekursion verstanden hat. *
