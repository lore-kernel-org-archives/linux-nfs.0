Received: from smtp-out2.suse.de (smtp-out2.suse.de [195.135.223.131])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 627E537D123
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 11:43:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.135.223.131
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772710999; cv=none; b=pbFErGrT9z9UPA7JW9+6JkCoLNVbyEZmxTkkqLYaIMR9otLUdACfA8nRPcYVPS5qyO4Fvm0l5BEcAbIfJqQy3bf+nB+OifIyRlI5fTp5vX3xg9FNqE5DNQtEvJhCkkIWBTactj57u40SFdvhlHys5oURbEP0g9gAMxftVHeYODY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772710999; c=relaxed/simple;
	bh=mu2BWbqg7C7djPHMpk1KEwnOCU6HSg4yCLHXL/v5V1Y=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=O5arXM7NjE+5h6wf6qDFMnMV1HwLfXZ7tCjLoWWBfeovukeEQq+xRgyFY9or+WlTqAELjn13R4/RQG9G5WsDw/p/8OynBBCG2uR/joJ1LIvpj/odGAAVU70T1LoXjevFPQ2v/+CoxMMq3L/EJ6jx756f/NM2qf0aaIMEcvgVvmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de; spf=pass smtp.mailfrom=suse.de; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=jbQ7I0Un; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=BckCzbH7; dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b=jbQ7I0Un; dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b=BckCzbH7; arc=none smtp.client-ip=195.135.223.131
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=suse.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=suse.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="jbQ7I0Un";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="BckCzbH7";
	dkim=pass (1024-bit key) header.d=suse.de header.i=@suse.de header.b="jbQ7I0Un";
	dkim=permerror (0-bit key) header.d=suse.de header.i=@suse.de header.b="BckCzbH7"
Received: from imap1.dmz-prg2.suse.org (imap1.dmz-prg2.suse.org [IPv6:2a07:de40:b281:104:10:150:64:97])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by smtp-out2.suse.de (Postfix) with ESMTPS id A712F5BCD5;
	Thu,  5 Mar 2026 11:43:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1772710996; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6/cO57o76fPesWyAidaOu+qFZhUKADpjA63gFQ6riK8=;
	b=jbQ7I0Un1hw0X73PCJ/MRDT+1euzR8g6JbO/XDKTgUFFLNU8OJLPBO7LmGjgK3vZvyrdm3
	PMdOMu2qQ6NjJsCDX4DD07QH7uAb6lllSlJVsPMdTnPVnhXpHt0i6+6RJI8uBE3PXzDJaH
	zfTiuZJlprI0thOcSlPfSvCg321ftGU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1772710996;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6/cO57o76fPesWyAidaOu+qFZhUKADpjA63gFQ6riK8=;
	b=BckCzbH7WRQ/992pT44zMmVLdiInnEF2A5+rPqgvwBMl/nO39vQV65bcBnRHkNxwaxseBp
	OKLHTgFgHq0656BQ==
Authentication-Results: smtp-out2.suse.de;
	dkim=pass header.d=suse.de header.s=susede2_rsa header.b=jbQ7I0Un;
	dkim=pass header.d=suse.de header.s=susede2_ed25519 header.b=BckCzbH7
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=suse.de; s=susede2_rsa;
	t=1772710996; h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6/cO57o76fPesWyAidaOu+qFZhUKADpjA63gFQ6riK8=;
	b=jbQ7I0Un1hw0X73PCJ/MRDT+1euzR8g6JbO/XDKTgUFFLNU8OJLPBO7LmGjgK3vZvyrdm3
	PMdOMu2qQ6NjJsCDX4DD07QH7uAb6lllSlJVsPMdTnPVnhXpHt0i6+6RJI8uBE3PXzDJaH
	zfTiuZJlprI0thOcSlPfSvCg321ftGU=
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=suse.de;
	s=susede2_ed25519; t=1772710996;
	h=from:from:reply-to:date:date:message-id:message-id:to:to:cc:cc:
	 mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=6/cO57o76fPesWyAidaOu+qFZhUKADpjA63gFQ6riK8=;
	b=BckCzbH7WRQ/992pT44zMmVLdiInnEF2A5+rPqgvwBMl/nO39vQV65bcBnRHkNxwaxseBp
	OKLHTgFgHq0656BQ==
Received: from imap1.dmz-prg2.suse.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by imap1.dmz-prg2.suse.org (Postfix) with ESMTPS id 7810B3EA68;
	Thu,  5 Mar 2026 11:43:16 +0000 (UTC)
Received: from dovecot-director2.suse.de ([2a07:de40:b281:106:10:150:64:167])
	by imap1.dmz-prg2.suse.org with ESMTPSA
	id opceHFRsqWmwQAAAD6G6ig
	(envelope-from <hare@suse.de>); Thu, 05 Mar 2026 11:43:16 +0000
Message-ID: <f6e8f196-7bd0-4f94-86e0-cb27c7e69d0a@suse.de>
Date: Thu, 5 Mar 2026 12:43:16 +0100
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v7 4/5] nvme-tcp: Support KeyUpdate
To: Alistair Francis <alistair23@gmail.com>
Cc: chuck.lever@oracle.com, hare@kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org,
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org,
 kbusch@kernel.org, axboe@kernel.dk, hch@lst.de, sagi@grimberg.me,
 kch@nvidia.com, Alistair Francis <alistair.francis@wdc.com>
References: <20260304053500.590630-1-alistair.francis@wdc.com>
 <20260304053500.590630-5-alistair.francis@wdc.com>
 <103c958f-d5f9-47d3-9be8-dd7225368fd5@suse.de>
 <CAKmqyKPdJ2bgT2JaXi_38obyFTjRQ_rR5EdGmP81so8MEJNRVw@mail.gmail.com>
Content-Language: en-US
From: Hannes Reinecke <hare@suse.de>
In-Reply-To: <CAKmqyKPdJ2bgT2JaXi_38obyFTjRQ_rR5EdGmP81so8MEJNRVw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
X-Rspamd-Action: no action
X-Rspamd-Server: rspamd2.dmz-prg2.suse.org
X-Spamd-Result: default: False [-4.51 / 50.00];
	BAYES_HAM(-3.00)[100.00%];
	NEURAL_HAM_LONG(-1.00)[-1.000];
	R_DKIM_ALLOW(-0.20)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	NEURAL_HAM_SHORT(-0.20)[-1.000];
	MIME_GOOD(-0.10)[text/plain];
	MX_GOOD(-0.01)[];
	DKIM_SIGNED(0.00)[suse.de:s=susede2_rsa,suse.de:s=susede2_ed25519];
	FREEMAIL_TO(0.00)[gmail.com];
	FUZZY_RATELIMITED(0.00)[rspamd.com];
	RBL_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	SPAMHAUS_XBL(0.00)[2a07:de40:b281:104:10:150:64:97:from];
	ARC_NA(0.00)[];
	RCPT_COUNT_TWELVE(0.00)[15];
	MIME_TRACE(0.00)[0:+];
	TO_MATCH_ENVRCPT_ALL(0.00)[];
	FREEMAIL_ENVRCPT(0.00)[gmail.com];
	RCVD_TLS_ALL(0.00)[];
	RCVD_COUNT_TWO(0.00)[2];
	FROM_EQ_ENVFROM(0.00)[];
	FROM_HAS_DN(0.00)[];
	TO_DN_SOME(0.00)[];
	DNSWL_BLOCKED(0.00)[2a07:de40:b281:104:10:150:64:97:from,2a07:de40:b281:106:10:150:64:167:received];
	RECEIVED_SPAMHAUS_BLOCKED_OPENRESOLVER(0.00)[2a07:de40:b281:106:10:150:64:167:received];
	MID_RHS_MATCH_FROM(0.00)[];
	DKIM_TRACE(0.00)[suse.de:+];
	RCVD_VIA_SMTP_AUTH(0.00)[];
	DBL_BLOCKED_OPENRESOLVER(0.00)[imap1.dmz-prg2.suse.org:helo,imap1.dmz-prg2.suse.org:rdns,suse.de:dkim,suse.de:mid,suse.de:email]
X-Rspamd-Queue-Id: A712F5BCD5
X-Spam-Flag: NO
X-Spam-Score: -4.51
X-Spam-Level: 

On 3/4/26 12:37, Alistair Francis wrote:
> On Wed, Mar 4, 2026 at 5:40 PM Hannes Reinecke <hare@suse.de> wrote:
>>
>> On 3/4/26 06:34, alistair23@gmail.com wrote:
>>> From: Alistair Francis <alistair.francis@wdc.com>
>>>
>>> If the nvme_tcp_try_send() or nvme_tcp_try_recv() functions return
>>> EKEYEXPIRED then the underlying TLS keys need to be updated. This occurs
>>> on an KeyUpdate event as described in RFC8446
>>> https://datatracker.ietf.org/doc/html/rfc8446#section-4.6.3.
>>>
>>> If the NVMe Target (TLS server) initiates a KeyUpdate this patch will
>>> allow the NVMe layer to process the KeyUpdate request and forward the
>>> request to userspace. Userspace must then update the key to keep the
>>> connection alive.
>>>
>>> This patch allows us to handle the NVMe target sending a KeyUpdate
>>> request without aborting the connection. At this time we don't support
>>> initiating a KeyUpdate.
>>>
>>> Signed-off-by: Alistair Francis <alistair.francis@wdc.com>
>>> ---
>>> v7:
>>>    - Use read_sock_cmsg instead of recvmsg() to handle KeyUpdate
>>> v6:
>>>    - Don't use `struct nvme_tcp_hdr` to determine TLS_HANDSHAKE_KEYUPDATE,
>>>      instead look at the cmsg fields.
>>>    - Don't flush async_event_work
>>> v5:
>>>    - Cleanup code flow
>>>    - Check for MSG_CTRUNC in the msg_flags return from recvmsg
>>>      and use that to determine if it's a control message
>>> v4:
>>>    - Remove all support for initiating KeyUpdate
>>>    - Don't call cancel_work() when updating keys
>>> v3:
>>>    - Don't cancel existing handshake requests
>>> v2:
>>>    - Don't change the state
>>>    - Use a helper function for KeyUpdates
>>>    - Continue sending in nvme_tcp_send_all() after a KeyUpdate
>>>    - Remove command message using recvmsg
>>>
>>>    drivers/nvme/host/tcp.c | 59 ++++++++++++++++++++++++++++++++++++++++-
>>>    1 file changed, 58 insertions(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/nvme/host/tcp.c b/drivers/nvme/host/tcp.c
>>> index 8b6172dd1c0f..ade11d2ac9ef 100644
>>> --- a/drivers/nvme/host/tcp.c
>>> +++ b/drivers/nvme/host/tcp.c
>>> @@ -171,6 +171,7 @@ struct nvme_tcp_queue {
>>>        bool                    tls_enabled;
>>>        u32                     rcv_crc;
>>>        u32                     snd_crc;
>>> +     key_serial_t            handshake_session_id;
>>>        __le32                  exp_ddgst;
>>>        __le32                  recv_ddgst;
>>>        struct completion       tls_complete;
>>> @@ -1361,6 +1362,59 @@ static int nvme_tcp_try_send(struct nvme_tcp_queue *queue)
>>>        return ret;
>>>    }
>>>
>>> +static void update_tls_keys(struct nvme_tcp_queue *queue)
>>> +{
>>> +     int qid = nvme_tcp_queue_id(queue);
>>> +     int ret;
>>> +
>>> +     dev_dbg(queue->ctrl->ctrl.device,
>>> +             "updating key for queue %d\n", qid);
>>> +
>>> +     ret = nvme_tcp_start_tls(&(queue->ctrl->ctrl),
>>> +                              queue, queue->ctrl->ctrl.tls_pskid,
>>> +                              HANDSHAKE_KEY_UPDATE_TYPE_RECEIVED);
>>> +
>>> +     if (ret < 0) {
>>> +             dev_err(queue->ctrl->ctrl.device,
>>> +                     "failed to update the keys %d\n", ret);
>>> +             nvme_tcp_fail_request(queue->request);
>>> +     }
>>> +}
>>> +
>>> +static int nvme_tcp_recv_cmsg(read_descriptor_t *desc,
>>> +                           struct sk_buff *skb,
>>> +                           unsigned int offset, size_t len,
>>> +                           u8 content_type)
>>> +{
>>> +     struct nvme_tcp_queue *queue = desc->arg.data;
>>> +     struct socket *sock = queue->sock;
>>> +     struct sock *sk = sock->sk;
>>> +
>>> +     switch (content_type) {
>>> +     case TLS_RECORD_TYPE_HANDSHAKE:
>>> +             if (len == 5) {
>>> +                     u8 header[5];
>>> +
>>> +                     if (!skb_copy_bits(skb, offset, header,
>>> +                                        sizeof(header))) {
>>> +                             if (header[0] == TLS_HANDSHAKE_KEYUPDATE) {
>>> +                                     dev_err(queue->ctrl->ctrl.device, "KeyUpdate message\n");
>>> +                                     release_sock(sk);
>>> +                                     update_tls_keys(queue);
>>> +                                     lock_sock(sk);
>>> +                                     return 0;
>>> +                             }
>>> +                     }
>>> +             }
>>> +
>>> +             break;
>>> +     default:
>>> +             break;
>>> +     }
>>
>> I think a simple 'if' condition would be sufficient here, or do you have
>> handling of other TLS record types queued somewhere?
>> And we should log unhandled TLS records.
> 
> I like this approach as it makes it really easy to handle more types
> in the future. I don't have any more record types queued anywhere so I
> can change it to an if statement.
> 
> Good point about logging unhandled records
> 
Which reminds me:
This is now a simple callback, and doesn't influence the main state machine.
In particular, we do _not_ reset the connection (as we did with the
original implementation) if we received an unhandled TLS record.

I guess we should be doing that nevertheless, as unhandled TLS records
also will include things like TLS Alert which really require us to
reset the connection.
Hmm?

Cheers,

Hannes
-- 
Dr. Hannes Reinecke                  Kernel Storage Architect
hare@suse.de                                +49 911 74053 688
SUSE Software Solutions GmbH, Frankenstr. 146, 90461 Nürnberg
HRB 36809 (AG Nürnberg), GF: I. Totev, A. McDonald, W. Knoblich
