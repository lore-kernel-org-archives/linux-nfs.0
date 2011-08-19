Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from talus.maths.usyd.edu.au ([129.78.68.1]:53985 "EHLO
	talus.maths.usyd.edu.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab1HSCK5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 22:10:57 -0400
Date: Fri, 19 Aug 2011 12:10:34 +1000
From: paul.szabo@sydney.edu.au
Message-Id: <201108190210.p7J2AYCB028893@bari.maths.usyd.edu.au>
To: neilb@suse.de
Subject: Re: Please support NSF squashing multiple groups
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110819110536.1f0133c6@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Dear Neil,

> If you are using kerberos authentication then you should be able
> to trust that any remote user really is who they say they are ...

Does that "work" also against the "evil remote root" e.g. when the
remote machine is compromised?

> If you are using NFSv4 and kerberos than there already exist
> interfaces to do what you want. See "man idmap.conf". ...

Sorry I do not use NFSv4 or kerberos, yet. Could you please point me
to references about idmap.conf, the ones I found suggest it only takes
[Mapping] settings for Nobody-User and Nobody-Group.


I agree with you that root_squash as currently implemented is rather
limited and useless, but am hoping that it can be improved.


Thanks for your help, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia
