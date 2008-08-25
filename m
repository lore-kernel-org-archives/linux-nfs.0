From: Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org>
Subject: Re: Linux NFS-HOWTO - improvement to Troubleshooting permission denied
Date: Mon, 25 Aug 2008 23:50:05 +0300
Message-ID: <87k5e4yg3m.fsf@jondo.cante.net>
References: <87skstbl7j.fsf@jondo.cante.net>
	<76bd70e30808250841v4e73c576qc1e68c85d88bb989@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "NFS HOWTO author" <smithere@gmail.com>,
	"http\:\/\/linux-nfs.org" <linux-nfs@vger.kernel.org>,
	chip@users.sourceforge.net, hjl@users.sourceforge.net,
	jbfields@users.sourceforge.net, jweber@users.sourceforge.net,
	marcmerlin@users.sourceforge.net, neilbrown@users.sourceforge.net,
	steved12345@users.sourceforge.net, trondmy@users.sourceforge.net
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from emh02.mail.saunalahti.fi ([62.142.5.108]:50641 "EHLO
	emh02.mail.saunalahti.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbYHYUuU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Aug 2008 16:50:20 -0400
In-Reply-To: <76bd70e30808250841v4e73c576qc1e68c85d88bb989-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Chuck Lever's message of "Mon, 25 Aug 2008 11:41:02 -0400")
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

"Chuck Lever" <chuck.lever@oracle.com> writes:
> On Mon, Aug 25, 2008 at 3:36 AM, Jari Aalto <jari.aalto-w6EBCRcXQ4deoWH0uzbU5w@public.gmane.org> wrote:
>>
>> Thank you for the NFS howto (last modified 2006). Please add further
>> diagnostics to section:
>>
>>        => "I do not have permission to access files on the mounted volume"
>>        http://nfs.sourceforge.net/nfs-howto/ar01s07.html#pemission_issues
>>
>> The error condition "Permission denied" also happens in certain NFS
>> (client/server) combinations and the workaround is to add additional
>> mount parameter at client:
>>
>>        sec=sys
>>
>> Please add this to the "#pemission_issues" (tag the word seems to have a
>> small typo).
>
> This is a known bug in nfs-utils 1.1.3 when used with older client
> kernels that do not support text-based mounts.
>
> Seems like an esoteric (ie not widespread) problem, but I could easily
> be wrong about that.

Please add the tip, although the bug may be fixed in later NFS releases.
There are great deal of hosts running old versions whose admins scratch
they head and seek for guidance from the HOWTO.

Mentioning "sec=sys" would have saved me countless of hours tracing what
was wrong in my setup[1]. Without to Bob <grantura <at> spamcop.net> and
his knowledge about Debian bug, I would never had resolved the issue in
decent time.

Jari

[1]
"NFS and no_root_squash - cannot write as root - permission denied"
http://thread.gmane.org/gmane.linux.debian.user/333162

http://bugs.debian.org/492970
