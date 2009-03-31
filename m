From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH v2 11/47] nfsd41: sessionid hashing
Date: Tue, 31 Mar 2009 10:02:07 +0300
Message-ID: <49D1BFEF.5030902@panasas.com>
References: <49CDDFC2.4070402@panasas.com> <1238229110-10339-1-git-send-email-bhalevy@panasas.com> <20090330200812.GI31237@fieldses.org> <49D12CD8.7060807@panasas.com> <20090330205900.GK31237@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:5674 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753527AbZCaHCM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Mar 2009 03:02:12 -0400
In-Reply-To: <20090330205900.GK31237@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 30, 2009, 23:59 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> On Mon, Mar 30, 2009 at 11:34:32PM +0300, Benny Halevy wrote:
>> On Mar. 30, 2009, 23:08 +0300, "J. Bruce Fields" <bfields@fieldses.org> wrote:
>>> On Sat, Mar 28, 2009 at 11:31:50AM +0300, Benny Halevy wrote:
>>>> +	return NULL;
>>>> +}
>>>> +
>>>> +/* caller must hold sessionid_lock */
>>>>  static void
>>>> -release_session(struct nfsd4_session *ses)
>>>> +unhash_session(struct nfsd4_session *ses)
>>>>  {
>>>>  	list_del(&ses->se_hash);
>>>>  	list_del(&ses->se_perclnt);
>>>> +}
>>>> +
>>>> +static void
>>>> +release_session(struct nfsd4_session *ses)
>>>> +{
>>>> +	spin_lock(&sessionid_lock);
>>>> +	unhash_session(ses);
>>>> +	spin_unlock(&sessionid_lock);
>>>>  	nfsd4_put_session(ses);
>>>>  }
>>> It's not obvious from the names what the difference between
>>> release_session() and nfsd4_put_session() is.
>>>
>>> How about just renaming release_session() to unhash_session(), and
>>> dumping hash_session?  The two list_del()'s don't need their own
>>> function.
>> We call unhash_session on its own later on from destroy_session,
>> then we destroy the callback client and finally put the session.
> 
> Oops, I see, I missed that.
> 
>> We can embed release_session into expire_client since it's
>> its only use though expire_client is hairy enough I'm not
>> sure we want to add more stuff into it.  If we're going
>> this direction, I'd consider refactoring it and taking
>> the many loops it's doing out into their own functions.
>> (we'll add a couple more for pNFS - for releasing layouts
>> and layoutrecalls)
> 
> Sounds OK.--b.

OK.  I'll send a cleanup patch that will bring the code into
the final version.  Eventually it'll split into one patch against
for-2.6.30 to refactor expire_client and the rest will be squashed
here. (plus the changes will percolate through to the pnfs branch)

Benny
