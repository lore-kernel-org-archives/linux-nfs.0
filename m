From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: Allow vers=4 and nfsvers=4 mount options
Date: Tue,  5 May 2009 14:46:42 -0700
Message-ID: <1241560004-16787-1-git-send-email-kevin.constantine@disneyanimation.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:48078 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759072AbZEEVqo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2009 17:46:44 -0400
Received: from chaos.fas.fa.disney.com (chaos.fas.fa.disney.com [172.30.160.30])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mailhub.fa.disney.com (Postfix) with ESMTP id DBF081253C1
	for <linux-nfs@vger.kernel.org>; Tue,  5 May 2009 14:46:44 -0700 (PDT)
Received: (from kconstan@localhost)
	by chaos.fas.fa.disney.com (8.13.8/8.13.7/Submit) id n45Lkiex016891
	for linux-nfs@vger.kernel.org; Tue, 5 May 2009 14:46:44 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I've run into a problem recently while trying to set up an environment for testing
nfsv4.  In our environment, we have a mixture of Linux, and OSX, and all of our mounts
are made via automount maps stored in LDAP which are shared among the platforms.  The
problem is made even more complicated by the fact that some of our file servers
support v4, while others do not.  This means that v4 mounts need to be specified on
a mount by mount basis, and only on certain test machines.

With nfsv4, Linux appears to use fstype=nfs4 to distinguish between v2,3 and v4, and
attempts to specify vers=4, or nfsvers=4 error.  OSX doesn't understand fstype
and mounts error when this option is encountered.  OSX instead relies on
vers=2,3,4 or nfsvers=2,3,4 to determine the version.  It appears that Solaris will
likely behave the same way as OSX based on the manpage, though I haven't tested it.

I've written the following patches to allow vers=4, and nfsvers=4 to be passed to
the mount command.  There's a patch for the text-based mount, and a second for the
older style mount options.  In both cases, I attempt to detect the vers= option
as early as possible in order to set fstype=nfs4, and then let the code continue on
as though the user had specified fstype=nfs4 on the command line.

Using these patches, I can now specify something like:
pamtest4  -rw,intr,hard,timeo=600$RSZ,vers=$NFSVERS     supportsv4:/vol/someexport
pamtest3  -rw,intr,hard,timeo=600$RSZ                   supportsv3only:/vol/v3export
in the automount map.  The variable $NFSVERS is set to 4 on the test clients, and 3
on production Linux machines, and OSX.

[PATCH 1/2] Allow nfs/vers=4 option in old style mount commands
[PATCH 2/2] Allow nfs/vers=4 option in text-based mount commands

-kevin
