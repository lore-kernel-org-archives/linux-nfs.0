Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34222 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752447Ab1KWOkK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 09:40:10 -0500
Message-ID: <4ECD05C8.3050809@RedHat.com>
Date: Wed, 23 Nov 2011 09:40:08 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/2] nfsidmap: Allow admins to clean up id mappings that
 have (ver 2)
References: <1321566696-7298-1-git-send-email-steved@redhat.com> <20111122205551.GF21451@fieldses.org>
In-Reply-To: <20111122205551.GF21451@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/22/2011 03:55 PM, J. Bruce Fields wrote:
> On Thu, Nov 17, 2011 at 04:51:34PM -0500, Steve Dickson wrote:
>> In working with the new idmapper, it became very apparent that
>> keys created from bad id mapping were very persistent and were
>> not easy disposed of. Unlike with rpc.idmapd, to git rid 
>> of bad id mapping one just needed to restart the daemon. 
>>
>> So I've added some functionality to the nfsidmap command
> 
> I wonder whether the nfsidmap command is the right place to do that.
> Currently it's only ever invoked by the kernel, and it seems a little
> odd to use the same command as an admin tool as well.  But I don't have
> a different suggestion.
Keeping all the "key management" stuff in one place makes sense to me.
  
> 
> Also, just out of curiosity: when were you typically running into this
> problem?  And if it was changing some sort of name-mapping
> configuration, is there some way to get this invoked automatically when
> that configuration changes?
Mostly syntax errors in /etc/request-key.conf and when a mapping
didn't happen due to a bug in libnfsidmap... 

Also naming resolution mechanisms are not perfect... there will 
be errors that will cause mapping failures.

What really caught my eye was with rpc.idmapd, to clear bad mappings,
you just restart the daemon. Now that rpc.idmapd will no longer 
need to run on the client (which is a good thing), I wanted to give
the admins some type of mechanism to clean up bad mappings.

steved.
 
> 
> --b.
> 
>> that will allow admins to:
>>
>>     - remove all the keys on the keyring.
>>     - remove a particular key from the keying.
>>
>> The intention is to allow admins a way to clean up the id
>> name space when name resolution mechanisms, like NIS or LDAP, 
>> fail and leave a large number (or small number) of id mapping 
>> pointing to nobody. 
>>
>> Note, for the second patch to work, there need to be a small 
>> kernel patch that will change the per-key permissions to
>> allow root to revoke them.
>>
>> Version 2:
>> - Added the fclose() calls as requested by the code review
>>
>> Steve Dickson (2):
>>   nfsidmap: Allow all keys to clear on the keyring
>>   nfsidmap: Allow a particular key to be revoked.
>>
>>  utils/nfsidmap/nfsidmap.c   |  145 +++++++++++++++++++++++++++++++++++++++++--
>>  utils/nfsidmap/nfsidmap.man |   27 ++++++++-
>>  2 files changed, 166 insertions(+), 6 deletions(-)
>>
>> -- 
>> 1.7.7
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
