From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] export dir thru 2 diff path names
Date: Mon, 10 Nov 2008 11:49:47 -0500
Message-ID: <20081110164947.GA17050@fieldses.org>
References: <478B90A1.5000900@bnl.gov>
	<1200330387.7470.11.camel@heimdal.trondhjem.org>
	<478B9A64.5030903@bnl.gov> <49147E79.6000508@bnl.gov>
	<20081109155831.GA24508@fieldses.org> <49185984.8010500@bnl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Sev Binello <sev-IGkKxAqZmp0@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:44687 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753268AbYKJQuo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 10 Nov 2008 11:50:44 -0500
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KzZyL-0007kw-K2
	for linux-nfs@vger.kernel.org; Tue, 11 Nov 2008 03:50:41 +1100
In-Reply-To: <49185984.8010500-IGkKxAqZmp0@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 10, 2008 at 10:55:48AM -0500, Sev Binello wrote:
> Well the simplest approach doesn't work.
> i.e put symb link and actual path in the export file & try exporting it
> Exportfs dereferences the link and states that duplicates are not allowed.

OK, makes sense.

You could mount --bind the filesystem at the other location instead of
symlinking.

The filehandles given to the client will be the same across the two
exports.  If you mount both from the same client, behavior may vary
across different clients (for example, as to whether they attempt to
share caches between the two), but I think it'd work.

(The question "why??!!??" does come to mind, though.)

--b.

>
> -Sev
>
> J. Bruce Fields wrote:
>> On Fri, Nov 07, 2008 at 12:44:25PM -0500, Sev Binello wrote:
>>   
>>> Can anyone tell me if it's ok to export the same file system
>>> through 2 different paths ( one is a link) ?
>>>     
>>
>> I actually don't know.  You could try it and tell us what you find
>> out....
>>
>> If you're exporting something *containing* the symlink and expecting the
>> client to traverse into the filesystem, be aware that symlinks over NFS
>> are actually interpreted (and followed) on the client--so they're
>> interpreted as *client-side* paths, not server-side.
>>
>> If the path you're exporting is itself a symlink--it probably depends on
>> how nfs-utils treats symlinks found in /etc/exports.  I'd have to try it
>> or check the code.
>>
>> Another way to export the filesystem in two different places would be
>> with mount --bind.
>>
>> --b.
>>   
>
>
> -- 
>
> Sev Binello
> Brookhaven National Laboratory
> Upton, New York
> 631-344-5647
> sev-IGkKxAqZmp0@public.gmane.org
>

-------------------------------------------------------------------------
This SF.Net email is sponsored by the Moblin Your Move Developer's challenge
Build the coolest Linux based applications with Moblin SDK & win great prizes
Grand prize is a trip for two to an Open Source event anywhere in the world
http://moblin-contest.org/redirect.php?banner_id=100&url=/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

